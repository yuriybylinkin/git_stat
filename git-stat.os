#Использовать 1commands

Функция СоздатьТаблицуСтатистики(СтрокаЗаголовков)

    ТаблицаСтатистики = Новый ТаблицаЗначений();

    ТаблицаСтатистики.Колонки.Добавить("start");
    ТаблицаСтатистики.Колонки.Добавить("end");
    
    Для Каждого Заголовок Из СтрРазделить(СтрокаЗаголовков, ",") Цикл
        ТаблицаСтатистики.Колонки.Добавить(Заголовок);    
    КонецЦикла;

    Возврат ТаблицаСтатистики;

КонецФункции

Процедура ЗаписатьТаблицуЗначенийНаДиск(ТаблицаЗначений, ИмяФайла)

    МассивСтрок = Новый Массив;
    МассивОписанияКолонок = Новый Массив;
    Для каждого Колонка Из ТаблицаЗначений.Колонки Цикл
        МассивОписанияКолонок.Добавить(Колонка.Имя);    
    КонецЦикла;

    МассивСтрок.Добавить(СтрСоединить(МассивОписанияКолонок, ";"));

    Для Каждого Строка Из ТаблицаЗначений Цикл

        ОписаниеСтроки = Новый Массив;
        Для каждого Колонка Из ТаблицаЗначений.Колонки Цикл
            ОписаниеСтроки.Добавить(Строка[Колонка.Имя]);    
        КонецЦикла;
        МассивСтрок.Добавить(СтрСоединить(ОписаниеСтроки, ";"));

    КонецЦикла;

    ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла);
	ЗаписьТекста.Записать(СтрСоединить(МассивСтрок, Символы.ПС));
	ЗаписьТекста.Закрыть();

КонецПроцедуры

СтрокаЗаголовков = "author,insertions,insertions_per,deletions,deletions_per,files,files_per,commits,commits_per,lines_changed,lines_changed_per";
ТаблицаСтатистики = СоздатьТаблицуСтатистики(СтрокаЗаголовков);

НачалоПериода = '2023-01-02';
Неделя = 60*60*24*7;
КонецПериода = НачалоПериода + Неделя - 1;

Пока КонецПериода <= ТекущаяДата() Цикл

    КомандныйФайл = Новый КомандныйФайл;
    КомандныйФайл.УстановитьПриложение("C:\Program Files\Git\bin\bash.exe");
    КомандныйФайл.УстановитьКодировкуВывода(КодировкаТекста.UTF8);
    КомандныйФайл.Создать("",".sh");

    КомандныйФайл.ДобавитьКоманду(СтрШаблон("export _GIT_SINCE=""""%1""""", Формат(НачалоПериода, "ДФ=yyyy-MM-dd")));
    КомандныйФайл.ДобавитьКоманду(СтрШаблон("export _GIT_UNTIL=""""%1""""", Формат(КонецПериода, "ДФ=yyyy-MM-dd")));
	КомандныйФайл.ДобавитьКоманду("export _GIT_BRANCH=master");
    КомандныйФайл.ДобавитьКоманду("cd C:/GIT/winow");
    КомандныйФайл.ДобавитьКоманду("C:/GIT/git-quick-stats/git-quick-stats -V");

    КодВозврата = КомандныйФайл.Исполнить();
    Вывод = КомандныйФайл.ПолучитьВывод();

    Вывод = СтрЗаменить(Вывод, СтрокаЗаголовков, "");
    Вывод = СокрЛП(Вывод);
    
    Для Каждого СтрокаВывода Из СтрРазделить(Вывод, Символы.ВК) Цикл
        
        Если СтрНайти(СтрокаВывода, СтрокаЗаголовков) > 0 Тогда
            Продолжить;
        КонецЕсли;

		Если Не ЗначениеЗаполнено(СтрокаВывода) Тогда
			Продолжить;
		КонецЕсли;

        ЭлементыСтрокиВывода = СтрРазделить(СокрЛП(СтрокаВывода), ",", Ложь);
		
        НоваяСтрока = ТаблицаСтатистики.Добавить();
        НоваяСтрока.start = НачалоПериода;
        НоваяСтрока.end = КонецПериода;
		МассивЗаголовков = СтрРазделить(СтрокаЗаголовков, ",");
		Для Каждого Заголовок Из МассивЗаголовков Цикл
			НоваяСтрока[Заголовок] = ЭлементыСтрокиВывода[МассивЗаголовков.Найти(Заголовок)];    
		КонецЦикла;
                
    КонецЦикла;

    НачалоПериода = НачалоПериода + Неделя;
    КонецПериода = КонецПериода + Неделя;
    
КонецЦикла;

ЗаписатьТаблицуЗначенийНаДиск(ТаблицаСтатистики, "git_stat.csv");