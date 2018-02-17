#!/bin/sh

# Скрипт агрегации MAGIC-интерфейсов модулей
#
# 1. Ищу все модули, предоставляющие MAGIC-интерфейс
#   1.1. Ищу все *.pbxproj
#   1.2. Определяю директорию, в которой находится *.xcodeproj
#   1.3. Нахожу все *+Magic.h файлы в этой директории
#   1.4. Если файлы есть, значит модуль имеет MAGIC-интерфейс
#
# 2. Для каждого модуля, имеющего MAGIC-интерфейсы
#   2.1. Определяю и валидирую MAGIC-интерфейсы
#     * Определяю основной MAGIC-интерфейс (например, "Products+Magic.h")
#     * Определяю дополнительные MAGIC-интерфейсы (например, "Products.Card+Magic.h", "Products.Router+Magic.h" ...)
#     * Проверяю, что все MAGIC-интерейсы имеют одинаковое имя основного интерйефса (например, "Products")
#   2.2. Переношу MAGIC-интерфейсы в Spellbook.h
#     * Каждый MAGIC-интерфейс проходит обработку:
#       1) Удаляются пустые строки и комментарии
#       2) К имени протокола добавляется префикс "MAGIC_MOCK"
#     * Переносится основной MAGIC-интерфейс
#     * Переносятся дополнительные MAGIC-интерфейсы
#   2.3. Создаю объединяющий протокол модуля
#     * Имя объединяющего протокола: MAGIC_<Имя файла *.xcodeproj>
#     * Объединяющий протокол наследуется от MagicCommonSpell
#     * Объединяющий протокол наследуется от основного MAGIC-интерфейса (если таковой имеется)
#     * Объединяющий протокол содержит набор @property, реализующих дополнительные MAGIC-интерфейсы
#     * Объединяющий протокол также предназначен для определения NSBundle, в котором лежит точка входа в модуль
#
# 3. Формирую объединяющий протокол "Spellbook"
#   Протокол "Spellbook" состоит из набора @property, каждое из которых
#   реализует соответствующий объединяющий протокол модуля:
#
# 4. Формирую Spellbook.m с кодом загрузки протоколов в Runtime
#   4.1. Для каждого сгенерированного протокола вызываю @protocol(<Имя протокола>)
#     * Это необходимо, чтобы корректно работал NSProxy при работе с протоколами из Spellbook.h
#
# 5. Сохраняю изменения
#   5.1. Вычисляю md5 для старого и нового Spellbook.h
#   5.2. Если суммы отличаются, то обновляю файл Spellbook.h
#

# Log variables
xcodeErrorPrefix="error: Magic error:"
xcodeWarningPrefix="warning: Magic error:"

# Errors
errorMoultipleMainSpells="в модуле должен быть только один базовый магический интерфейс"
errorWrongMagicFileName="некорректное имя файла с магическим интерфейсом"

# Parse variables
fileDelimiter=''
magicFileRegexp="^([A-Za-z0-9_]+)(\.[A-Za-z0-9_]+)?\+Magic.h$"
commonProtocol="MagicCommonSpell"
mainProtocolPrefix="MAGIC_MOCK_"
auxiliaryProtocolPrefix="MAGIC_"
chapterCounter=0

# File variables
fileName="Spellbook"
magicDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
headerFile="$magicDir/$fileName.h"
newHeaderFile="$magicDir/$fileName~temp.h"
loaderFile="$magicDir/$fileName.m"
newLoaderFile="$magicDir/$fileName~temp.m"


function Log()
{
  if [[ -n $CONFIGURATION ]]; then
    echo -e "$1"
  else
    echo "$1"
  fi
}

function LogExtended()
{
  extendedLogEnabled=true

  if [[ $extendedLogEnabled == true ]]; then
    if [[ -n $CONFIGURATION ]]; then
      echo -e "$1"
    else
      echo "$1"
    fi
  fi
}

function findFileList()
{
  path=$1
  pattern=$2

  funcOut_searchResults=""
  find $path -type f -name $pattern -print0 >tmpfile
  while read -rd $'\0' foundFileName; do
    if [[ -n "$funcOut_searchResults" ]]; then
      funcOut_searchResults+=$fileDelimiter
    fi
    funcOut_searchResults+=$foundFileName
  done <tmpfile
  rm -f tmpfile
}

function abortSpellbookGenerating()
{
  Log "\n\nСоставление книги заклинаний прервано."
  rm -f $newHeaderFile
  rm -f $newLoaderFile
  exit 1
}

function printSpellbookHeader()
{
  Log "\
//
//  $fileName.h
//  -=Книга Заклинаний=-
//
//  Author: $magicDir/MakeMagic.sh
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol $commonProtocol;" > $newHeaderFile
}

function printSpellbookLoaderHead()
{
  Log "\
//
//  $fileName.m
//  Загрузчик протоколов Spellbook в Runtime
//
//  Author: $magicDir/MakeMagic.sh
//  Copyright © 2018 SberTech. All rights reserved.
//

#import \"$fileName.h\"

@interface SBMMagicProtocolLoader : NSObject
@end

@implementation SBMMagicProtocolLoader

+ (void)load
{
	(void)@protocol(MagicCommonSpell);
	(void)@protocol(Spellbook);" > $newLoaderFile
}

function printSpellbookChapter()
{
  moduleName=$1
  chapterCounter=$((chapterCounter+1))
  Log "\n\n\
/**
  * Глава $chapterCounter. \"$moduleName\".
  */" >> $newHeaderFile
}

function printSpellbookBaldMagicSpell()
{
  inputFile=$1

  commentOpened=false
  commentBeganRegexp="^(/\*\*)(.*)$"
  commentEndRegexp="^(.*)(\*/)(.*)$"
  whitespaceRegexp="^[[:space:]]*$"
  commentLineRegexp="^//(.*)$"
  magicProtocolRegexp="^@protocol[[:space:]]+([A-Za-z0-9_]+)([^;]*)$"

  Log "/// Мок протокола из файла: @link file://${inputFile#./}" >> $newHeaderFile

  funcOut_magicProtocolName=""
  while read line; do
    # Обработка комментариев формата /** ... */
    if [[ $commentOpened == true ]]; then
      if [[ $line =~ $commentEndRegexp ]]; then
        LogExtended "$line [comment END]"
        commentOpened=false
      else
        LogExtended "$line [comment ON]"
      fi
      continue
    fi
    if [[ $line =~ $commentBeganRegexp ]]; then
      if [[ $line =~ $commentEndRegexp ]]; then
        LogExtended "$line [comment BEGAN+END]"
      else
        LogExtended "$line [comment BEGAN]"
        commentOpened=true
      fi
      continue
    fi
    # Обработка комментариев формата //
    if [[ $line =~ $commentLineRegexp ]]; then
      LogExtended "$line [comment LINE]"
      continue
    fi
    # Обработка пустых строк
    if [[ $line =~ $whitespaceRegexp ]]; then
      LogExtended "$line [whitespace]"
      continue
    fi

    # Все остальное считается полезным кодом, который идет в Spellbook
    if [[ $line =~ $magicProtocolRegexp ]]; then
      magicProtocolName=${BASH_REMATCH[1]}
      magicProtocolAppendix=${BASH_REMATCH[2]}
      LogExtended "$line [protocol]"
      Log "@protocol ${mainProtocolPrefix}${magicProtocolName}${magicProtocolAppendix}" >> $newHeaderFile
      funcOut_magicProtocolName="${mainProtocolPrefix}${magicProtocolName}"
    else
      LogExtended "$line [code]"
      Log $line >> $newHeaderFile
    fi
  done < $inputFile
}


#------------------------------------------------------------
#----------------------SCRIPT-BODY---------------------------
#------------------------------------------------------------

Log "
--=Книга Заклинаний=--
Выполняю поиск МАГИИ в проекте: $PWD"
cd ../

spellbookPropertyList=()
printSpellbookHeader
printSpellbookLoaderHead


# Итерирую по файлам проектов в workspace
findFileList . "*.pbxproj"
IFS=$fileDelimiter pbxprojList=($funcOut_searchResults)
IFS=$'\n' pbxprojList=($(sort <<<"${pbxprojList[*]}"))
for pbxproj in "${pbxprojList[@]}"; do
  if [[ "$pbxproj" == "" ]]; then continue; fi
  xcodeproj="${pbxproj%/*}"
  moduleDir="${xcodeproj%/*}"
  frameworkName=$(basename "$xcodeproj" ".xcodeproj")

  # Определяю, есть ли магические файлы в найденном проекте
  findFileList $moduleDir "*+Magic.h"
  IFS=$fileDelimiter magicFileList=($funcOut_searchResults)
  if [[ ${magicFileList[@]} ]]; then
    magicModuleName="${moduleDir##*/}"
    Log "\n\n Найден модуль с магией: \"$magicModuleName\""

    # Создаю и валидирую структуру магических файлов
    moduleMainSpell=""
    moduleMainSpellName=""
    moduleAuxiliarySpells=()
    moduleAuxiliarySpellNames=()
    for magicFile in ${magicFileList[@]}; do
      if [[ "$magicFile" == "" ]]; then continue; fi
      magicFileName="${magicFile##*/}"
      if [[ $magicFileName =~ $magicFileRegexp ]]; then
        magicFileMainSpellName=${BASH_REMATCH[1]}
        magicFileAuxiliarySpellName=${BASH_REMATCH[2]}
        if [[ -n "$moduleMainSpell" && "$magicFileAuxiliarySpellName" == "" ]]; then
          Log "$xcodeErrorPrefix $errorMoultipleMainSpells\nModule: \"$moduleName\"\nMagic files: \"${magicFileList[@]}\""
          abortSpellbookGenerating
        fi
        if [[ "$moduleMainSpellName" == "" ]]; then
          moduleMainSpellName=$magicFileMainSpellName
        fi
        if [[ "$moduleMainSpell" == "" && "$magicFileAuxiliarySpellName" == "" ]]; then
          moduleMainSpell=$magicFile
        fi
        if [[ -n "$magicFileAuxiliarySpellName" ]]; then
          moduleAuxiliarySpells+=($magicFile)
          moduleAuxiliarySpellNames+=(${magicFileAuxiliarySpellName:1})
        fi
      else
        Log "$xcodeErrorPrefix $errorWrongMagicFileName\nFile \"$magicFileName\"\nLocation: \"$magicFile\"\nRegexp: \"$regexp\""
        abortSpellbookGenerating
      fi
    done

    # Печатаю обработанное содержимое магических файлов в книгу заклинаний
    printSpellbookChapter $magicModuleName
    mainSpellProtocolName=""
    auxiliarySpellProtocolName="${auxiliaryProtocolPrefix}${frameworkName}"
    auxiliarySpellProtocol="@protocol $auxiliarySpellProtocolName <$commonProtocol"
    if [[ -n "$moduleMainSpell" ]]; then
      Log "\nОсновное заклинание: $moduleMainSpell"
      printSpellbookBaldMagicSpell $moduleMainSpell
      mainSpellProtocolName=$funcOut_magicProtocolName
      auxiliarySpellProtocol+=", $mainSpellProtocolName"
    fi
    auxiliarySpellProtocol+=">\n"
    if [[ ${moduleAuxiliarySpells[@]} ]]; then
      for spellIndex in "${!moduleAuxiliarySpells[@]}"; do
        auxiliarySpell="${moduleAuxiliarySpells[$spellIndex]}"
        auxiliarySpellName="${moduleAuxiliarySpellNames[$spellIndex]}"
        Log "\nСпециальное заклинание [$auxiliarySpellName]: $auxiliarySpell"
        printSpellbookBaldMagicSpell $auxiliarySpell
        auxiliarySpellProtocol+="@property (nonatomic, readonly) id<$funcOut_magicProtocolName> $auxiliarySpellName;\n"
      done
    fi
    auxiliarySpellProtocol+="@end"
	Log "/// Объединяющий протокол модуля \"$frameworkName\"" >> $newHeaderFile
    Log $auxiliarySpellProtocol >> $newHeaderFile
    Log "	(void)@protocol($auxiliarySpellProtocolName);" >> $newLoaderFile

    spellbookProperty="@property (nonatomic, readonly) id<$auxiliarySpellProtocolName> $moduleMainSpellName;"
    spellbookPropertyList+=($spellbookProperty)
  fi
done

Log "

/**
  * Объединяющий магический протокол
  */
@protocol $fileName" >> $newHeaderFile
for spellbookProperty in "${spellbookPropertyList[@]}"; do
  Log $spellbookProperty >> $newHeaderFile
done
Log "@end" >> $newHeaderFile
Log "}\n\n@end" >> $newLoaderFile


# Сравниваю хэши файлов. Если файл не изменился, не обновляем его, чтобы не перебилдивать весь проект.
if [ -f $headerFile ]; then
  oldFileHash=`md5 -q "$headerFile"`
fi
newFileHash=`md5 -q "$newHeaderFile"`
if [ "$oldFileHash" = "$newFileHash" ]; then
  rm -f $newHeaderFile
  rm -f $newLoaderFile
  Log "\nСтарая книга заклинаний все еще актуальна: $headerFile."
else
  rm -f $headerFile
  mv $newHeaderFile $headerFile
  rm -f $loaderFile
  mv $newLoaderFile $loaderFile
  Log "\nКнига заклинаний обновлена: $headerFile."
fi

Log "Выполнено за $SECONDS сек."
