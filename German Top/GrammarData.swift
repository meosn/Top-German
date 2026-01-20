import Foundation

// MARK: - Структуры контента
struct GrammarPart: Identifiable {
    let id = UUID()
    let title: String
    let chapters: [GrammarChapter]
}

struct GrammarChapter: Identifiable {
    let id = UUID()
    let title: String
    let lessons: [GrammarLesson]
}

struct GrammarLesson: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let sections: [LessonSection]
}

struct LessonSection: Identifiable {
    let id = UUID()
    let header: String?
    let text: String
    let germanExample: String?
}

// MARK: - Данные (Глава 1: Существительное по Тагилю)
struct GrammarData {
    static let contents: [GrammarPart] = [
        GrammarPart(title: "ЧАСТЬ I. МОРФОЛОГИЯ", chapters: [
            
            // --- ГЛАВА 1: СУЩЕСТВИТЕЛЬНОЕ ---
            GrammarChapter(title: "1. Имя существительное", lessons: [
                
                // 1.1 Артикль
                GrammarLesson(title: "1.1 Артикль", description: "Функции, склонение и употребление", sections: [
                    LessonSection(header: "1.1.1 Функция артикля", text: "Артикль — это служебное слово, которое выражает грамматические категории рода, числа и падежа, а также категорию определенности/неопределенности.", germanExample: "Das ist ein Buch. Das Buch ist interessant."),
                    LessonSection(header: "1.1.2 Склонение артикля", text: "Определенный: Nom: der/die/das; Gen: des/der/des; Dat: dem/der/dem; Akk: den/die/das.\nНеопределенный: Nom: ein/eine/ein; Gen: eines/einer/eines; Dat: einem/einer/einem; Akk: einen/eine/ein.", germanExample: "Ich gebe dem Bruder einen Apfel."),
                    LessonSection(header: "1.1.3(1) Определенный артикль", text: "Употребляется, когда предмет уже известен, является единственным в своем роде или имеет при себе определение.", germanExample: "Die Sonne scheint. Der Schrank in der Ecke."),
                    LessonSection(header: "1.1.3(3) Нулевой артикль", text: "Артикль отсутствует перед названиями городов, стран среднего рода, профессиями (после sein), веществами и абстрактными понятиями.", germanExample: "Ich lebe in Berlin. Er ist Ingenieur. Hast du Zeit?")
                ]),
                
                // 1.2 Род
                GrammarLesson(title: "1.2 Грамматический род", description: "Определение рода по значению и форме", sections: [
                    LessonSection(header: "1.2.1 По значению (der)", text: "Мужской род: мужской пол, времена года, месяцы, дни недели, стороны света, осадки, камни/минералы.", germanExample: "Der Montag, der Sommer, der Regen, der Rubin."),
                    LessonSection(header: "1.2.2 По форме (die/das)", text: "Женский род (-ung, -heit, -keit, -schaft, -ei). Средний род (-chen, -lein, -ment, -tum, -um).", germanExample: "Die Freiheit, die Leitung, das Mädchen, das Dokument."),
                    LessonSection(header: "1.2.4 Сложные слова", text: "Род сложного существительного всегда определяется по последнему слову.", germanExample: "Der Tisch + die Decke = die Tischdecke.")
                ]),
                
                // 1.3 Склонение
                GrammarLesson(title: "1.3 Склонение существительных", description: "Сильное, слабое, женское и смешанное", sections: [
                    LessonSection(header: "1.3.1 Сильное склонение", text: "Относится большинство мужского рода и все среднего. В Genitiv ед.ч. получают окончание -(e)s.", germanExample: "Der Tag -> des Tages. Das Kind -> des Kindes."),
                    LessonSection(header: "1.3.2 Слабое склонение (n-Deklination)", text: "Только мужской род. Получают окончание -en во всех падежах, кроме Nominativ. Обычно это одушевленные существительные на -e.", germanExample: "Der Junge -> dem Jungen. Der Student -> den Studenten."),
                    LessonSection(header: "1.3.5 Склонение собственных имен", text: "Имена и фамилии получают -s только в Genitiv.", germanExample: "Goethes Gedichte. Marias Tasche.")
                ]),
                
                // 1.4 Множественное число
                GrammarLesson(title: "1.4 Множественное число", description: "5 типов образования Plural", sections: [
                    LessonSection(header: "Тип I (-e)", text: "Многие слова мужского рода. Часто с умлаутом.", germanExample: "Der Tisch -> die Tische. Der Ball -> die Bälle."),
                    LessonSection(header: "Тип II (-en / -n)", text: "Почти все слова женского рода и слова слабого склонения.", germanExample: "Die Frau -> die Frauen. Die Blume -> die Blumen."),
                    LessonSection(header: "Тип III (без окончания)", text: "Слова на -er, -el, -en.", germanExample: "Der Lehrer -> die Lehrer. Das Fenster -> die Fenster."),
                    LessonSection(header: "Тип IV (-er)", text: "Многие слова среднего рода. Всегда с умлаутом.", germanExample: "Das Bild -> die Bilder. Das Buch -> die Bücher."),
                    LessonSection(header: "Тип V (-s)", text: "Заимствования и сокращения.", germanExample: "Das Auto -> die Autos. Книга -> die Kinos.")
                ])
            ]),
            GrammarChapter(title: "2. Глагол", lessons: [
                
                // 2.1 Основные формы
                GrammarLesson(title: "2.1 Основные формы глагола", description: "Infinitiv, Präteritum, Partizip II", sections: [
                    LessonSection(header: "2.1.1 Слабые глаголы", text: "Образуются по стандартной схеме: суффикс -(e)te в претеритуме и приставка ge- + суффикс -(e)t в Partizip II.", germanExample: "machen — machte — gemacht."),
                    LessonSection(header: "2.1.2 Сильные глаголы", text: "Характеризуются изменением корневого гласного. Partizip II оканчивается на -en.", germanExample: "singen — sang — gesungen. fahren — fuhr — gefahren."),
                    LessonSection(header: "2.1.3 Приставки", text: "Отделяемые приставки всегда под ударением и уходят в конец предложения в Präsens и Präteritum. Неотделяемые (be-, ge-, er-, ver-, zer-, ent-, emp-, miss-) приставку ge- в Partizip II не получают.", germanExample: "aufstehen — я встаю: Ich stehe auf. verstehen — я понял: Ich habe verstanden.")
                ]),
                
                // 2.3 Временные формы
                GrammarLesson(title: "2.3 Временные формы", description: "От настоящего до будущего времени", sections: [
                    LessonSection(header: "2.3.1 Презенс (Präsens)", text: "Настоящее время. Сильные глаголы с корневыми -a-, -e- меняют их во 2-м и 3-м лице ед.ч.", germanExample: "Ich fahre. Du fährst. Er fährt. Ich lese. Du liest."),
                    LessonSection(header: "2.3.2 Претерит (Präteritum)", text: "Прошедшее повествовательное время (книжное).", germanExample: "Es war einmal ein König."),
                    LessonSection(header: "2.3.3 Перфект (Perfekt)", text: "Разговорное прошедшее время. Образуется: haben/sein + Partizip II. Sein используется с глаголами движения и перемены состояния.", germanExample: "Ich habe das gemacht. Er ist nach Berlin gefahren.")
                ]),
                
                // 2.4 Пассив
                GrammarLesson(title: "2.4 Пассив (Страдательный залог)", description: "Действие над объектом", sections: [
                    LessonSection(header: "Образование", text: "Образуется при помощи глагола werden в соответствующем времени + Partizip II основного глагола.", germanExample: "Das Haus wird gebaut. (Дом строится)"),
                    LessonSection(header: "Пассив состояния", text: "Используется глагол sein, когда важен результат, а не процесс.", germanExample: "Das Fenster ist geöffnet. (Окно открыто)")
                ]),
                
                // 2.11 Управление
                GrammarLesson(title: "2.11 Глагольное управление", description: "Rektion: Глаголы с предлогами", sections: [
                    LessonSection(header: "Предложное управление", text: "Многие глаголы требуют после себя строго определенный предлог и падеж.", germanExample: "Warten auf + Akk. Ich warte auf dich. Denken an + Akk. Er denkt an die Arbeit.")
                ])
            ]),
                        GrammarChapter(title: "3. Местоимение", lessons: [
                            GrammarLesson(title: "3.1 Личные и притяжательные", description: "Склонение ich, du, mein, dein", sections: [
                                LessonSection(header: "Личные местоимения", text: "Склоняются по падежам: ich-mir-mich, du-dir-dich, er-ihm-ihn, sie-ihr-sie, es-ihm-es.", germanExample: "Ich helfe dir. Er sieht mich."),
                                LessonSection(header: "Притяжательные", text: "Выражают принадлежность. Склоняются как неопределенный артикль в ед.ч. и как определенный во мн.ч.", germanExample: "Das есть мой словарь: Das ist mein Wörterbuch. В твоей сумке: In deiner Tasche.")
                            ]),
                            GrammarLesson(title: "3.8 Местоимение es", description: "Безличное и указательное употребление", sections: [
                                LessonSection(header: "Употребление", text: "Es используется в безличных предложениях (погода, время) и как дополнение.", germanExample: "Es regnet. Wie spät ist es? Ich weiß es не знаю.")
                            ])
                        ]),
                        
                        // --- ГЛАВА 4: ИМЯ ПРИЛАГАТЕЛЬНОЕ ---
                        GrammarChapter(title: "4. Имя прилагательное", lessons: [
                            GrammarLesson(title: "4.1 Склонение прилагательных", description: "Слабое, сильное и смешанное", sections: [
                                LessonSection(header: "4.1.1 Слабое (после опред. артикля)", text: "Прилагательное получает окончание -e (ед.ч. Nom) или -en (все остальное).", germanExample: "Der gute Mann. Die guten Leute."),
                                LessonSection(header: "4.1.2 Сильное (без артикля)", text: "Прилагательное само выполняет роль артикля и берет его окончания.", germanExample: "Kalter Tee. Mit frischem Brot."),
                                LessonSection(header: "4.1.3 Смешанное (после ein/kein/mein)", text: "В Nom и Akk ед.ч. берет окончания сильного склонения, в остальных — слабого.", germanExample: "Ein guter Freund. Моего старого друга: Meines alten Freundes.")
                            ]),
                            GrammarLesson(title: "4.2 Степени сравнения", description: "Positiv, Komparativ, Superlativ", sections: [
                                LessonSection(header: "Образование", text: "Сравнительная: суффикс -er. Превосходная: am ...-(e)sten.", germanExample: "Klein — kleiner — am kleinsten. Gut — besser — am besten.")
                            ])
                        ]),
                        
                        // --- ГЛАВА 5: НАРЕЧИЕ ---
                        GrammarChapter(title: "5. Наречие", lessons: [
                            GrammarLesson(title: "5.2 Классификация наречий", description: "Место, время и причина", sections: [
                                LessonSection(header: "Местоименные наречия", text: "Указывают на предметы через предлоги: da(r) + предлог.", germanExample: "Wovon sprichst du? — Davon. (О чем ты говоришь? — Об этом.)")
                            ])
                        ]),
                        
                        // --- ГЛАВА 6: ИМЯ ЧИСЛИТЕЛЬНОЕ ---
                        GrammarChapter(title: "6. Имя числительное", lessons: [
                            GrammarLesson(title: "6.1 Количественные и порядковые", description: "Образование и склонение", sections: [
                                LessonSection(header: "Порядковые", text: "До 19 добавляется суффикс -te, после 20 — -ste. Склоняются как прилагательные.", germanExample: "Der erste Mai. Heute ist der zwanzigste Januar.")
                            ])
                        ]),
            // --- ГЛАВА 7: СЛОВООБРАЗОВАНИЕ ---
                        GrammarChapter(title: "7. Словообразование", lessons: [
                            GrammarLesson(title: "7.1 Суффиксы существительных", description: "Как суффикс определяет род", sections: [
                                LessonSection(header: "Мужской род", text: "Суффиксы: -er (профессии), -ismus, -ist, -ent.", germanExample: "Der Lehrer, der Optimismus, der Student."),
                                LessonSection(header: "Женский род", text: "Суффиксы: -ung, -heit, -keit, -schaft, -ei, -tät, -ik.", germanExample: "Die Zeitung, die Freiheit, die Freundschaft."),
                                LessonSection(header: "Средний род", text: "Суффиксы: -chen, -lein, -tum, -ment.", germanExample: "Das Mädchen, das Eigentum, das Dokument.")
                            ])
                        ])
                    ]), // Конец ЧАСТИ I

                    // --- ЧАСТЬ II. СИНТАКСИС ---
                    GrammarPart(title: "ЧАСТЬ II. СИНТАКСИС", chapters: [
                        GrammarChapter(title: "8. Структура предложения", lessons: [
                            GrammarLesson(title: "8.1 Порядок слов", description: "Место глагола в предложении", sections: [
                                LessonSection(header: "Прямой порядок", text: "Подлежащее на 1-м месте, сказуемое (глагол) — на 2-м.", germanExample: "Мы учим немецкий язык: Wir lernen die deutsche Sprache."),
                                LessonSection(header: "Обратный порядок", text: "Если на 1-м месте стоит обстоятельство (времени, места), глагол остается на 2-м, а подлежащее уходит на 3-е.", germanExample: "Сегодня мы учим немецкий: Heute lernen wir Deutsch.")
                            ]),
                            GrammarLesson(title: "8.5 Рамочная конструкция", description: "Satzklammer — основа немецкого языка", sections: [
                                LessonSection(header: "Принцип рамки", text: "Изменяемая часть глагола стоит на 2-м месте, а неизменяемая (инфинитив или причастие) — в самом конце.", germanExample: "Ich muss сегодня рано встать: Ich muss heute früh aufstehen. Я это уже сделал: Ich habe это уже gemacht.")
                            ])
                        ]),
                        
                        GrammarChapter(title: "9. Сложносочинённые предложения", lessons: [
                            GrammarLesson(title: "9.1 Союзы в позиции 0", description: "ADUSO (Aber, Denn, Und, Sondern, Oder)", sections: [
                                LessonSection(header: "Правило", text: "Эти союзы не занимают места. После них идет прямой порядок слов.", germanExample: "Ich bin müde, aber ich arbeite дальше. (Я устал, но работаю дальше.)")
                            ])
                        ]),
                        
                        GrammarChapter(title: "10. Придаточные предложения", lessons: [
                            GrammarLesson(title: "10.1 Основные типы", description: "Порядок слов с союзами dass, weil, wenn", sections: [
                                LessonSection(header: "Глагол в конец!", text: "В придаточном предложении изменяемый глагол ВСЕГДА стоит на последнем месте.", germanExample: "Я знаю, что ты придешь: Ich weiß, dass du kommst. Мы идем гулять, потому что погода хорошая: Wir gehen spazieren, weil das Wetter gut ist.")
                            ])
                        ]),
                        // --- ГЛАВА 11: ОТРИЦАНИЕ ---
                                    GrammarChapter(title: "11. Отрицание", lessons: [
                                        GrammarLesson(title: "Nicht или Kein?", description: "Правила использования отрицаний", sections: [
                                            LessonSection(header: "Отрицание kein", text: "Используется только перед существительными, которые в утвердительном предложении имели бы неопределенный артикль или были бы без артикля.", germanExample: "Das ist kein Buch. Ich habe keine Zeit."),
                                            LessonSection(header: "Отрицание nicht", text: "Отрицает глаголы, прилагательные, наречия или все предложение целиком. Обычно стоит в конце предложения, но перед второй частью глагола или прилагательным.", germanExample: "Ich verstehe dich nicht. Das ist nicht gut. Er kommt heute nicht.")
                                        ])
                                    ]),

                                    // --- ГЛАВА 12: ПРЕДЛОГ ---
                                    GrammarChapter(title: "12. Предлог", lessons: [
                                        GrammarLesson(title: "Группы по падежам", description: "Управление предлогов", sections: [
                                            LessonSection(header: "Только Akkusativ", text: "Предлоги: durch, für, gegen, ohne, um, bis.", germanExample: "Das подарок для тебя: Das Geschenk ist für dich. Мы идем вокруг дома: Wir gehen um das Haus."),
                                            LessonSection(header: "Только Dativ", text: "Предлоги: mit, nach, aus, zu, von, bei, seit, außer, entgegen.", germanExample: "Я еду с другом: Ich fahre mit dem Freund. После работы: Nach der Arbeit."),
                                            LessonSection(header: "Двойное управление (Wechsel)", text: "Wo? -> Dativ, Wohin? -> Akkusativ. Предлоги: in, an, auf, под, над, за, перед, между.", germanExample: "Я иду в кино (куда?): Ich gehe ins Kino (Akk). Я в кино (где?): Ich bin im Kino (Dat).")
                                        ]),
                                        GrammarLesson(title: "Предлоги с Genitiv", description: "Официальный стиль", sections: [
                                            LessonSection(header: "Основные", text: "während (во время), wegen (из-за), statt (вместо), trotz (несмотря на).", germanExample: "Während der Pause. Wegen des Regens (Из-за дождя).")
                                        ])
                                    ]),

                                    // --- ГЛАВА 13: СОЮЗЫ ---
                                    GrammarChapter(title: "13. Союзы", lessons: [
                                        GrammarLesson(title: "Логическая связь", description: "Соединение частей предложения", sections: [
                                            LessonSection(header: "Парные союзы", text: "entweder ... oder (или... или), sowohl ... als auch (как... так и), weder ... noch (ни... ни).", germanExample: "Entweder du komшь или я: Entweder du kommst или я остаюсь: ...oder ich bleibe.")
                                        ])
                                    ]),

                                    // --- ГЛАВА 14: ЧАСТИЦЫ ---
                                    GrammarChapter(title: "14. Частицы", lessons: [
                                        GrammarLesson(title: "Модальные частицы", description: "Оттенки смысла (doch, mal, halt)", sections: [
                                            LessonSection(header: "Функция", text: "Частицы не меняют смысл предложения, но меняют его тон (просьба, удивление, раздражение).", germanExample: "Komm mal her! (Зайди-ка сюда). Das ist doch klar! (Это же ясно!)")
                                        ])
                                    ])
                                ]), // Конец ЧАСТИ II

                                // --- ЧАСТЬ III. ОРФОГРАФИЯ ---
                                GrammarPart(title: "ЧАСТЬ III. ОРФОГРАФИЯ И ПУНКТУАЦИЯ", chapters: [
                                    GrammarChapter(title: "16. Правила орфографии", lessons: [
                                        GrammarLesson(title: "ss и ß", description: "Когда писать эс-цет", sections: [
                                            LessonSection(header: "Правило", text: "ß пишется после длинных гласных и дифтонгов. ss пишется после коротких гласных.", germanExample: "Groß (большой), Kuss (поцелуй)")
                                        ])
                                    ])
                            
                        
            
        ])
                   
        
    ]
    
}
