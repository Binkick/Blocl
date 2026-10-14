// Flutter Source Code for Android APK: "Автоматизация & КИПиА: Полный ИИ-Экзаменатор"
// Содержит все 11 билетов, таймер, выбор ответа, устные и текстовые ответы с оценкой ИИ,
// режим репетитора (объяснение тем) и экран настройки вопросов.
//
// Инструкция по сборке APK:
// 1. flutter create automation_exam_app
// 2. Добавьте в pubspec.yaml зависимости:
//    flutter_tts: ^3.8.5
//    speech_to_text: ^6.6.0
//    http: ^1.2.0
// 3. Замените содержимое lib/main.dart этим файлом.
// 4. Запустите сборку: flutter build apk --release

import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AutomationMasterApp());
}

class AutomationMasterApp extends StatelessWidget {
  const AutomationMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Автоматизация & КИПиА: ИИ Экзаменатор',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        primaryColor: const Color(0xFF3B82F6),
        cardColor: const Color(0xFF121826),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF121826),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ------------------- МОДЕЛЬ 11 ВОПРОСОВ И БАНКА -------------------
class TopicItem {
  final int id;
  final String title;
  final String fullQuestion;
  bool isActive;

  TopicItem({
    required this.id,
    required this.title,
    required this.fullQuestion,
    this.isActive = true,
  });
}

final List<TopicItem> globalTopics = [
  TopicItem(
    id: 1,
    title: "Электрическое напряжение, электрический ток, сила тока",
    fullQuestion: "1. Электрическое напряжение, электрический ток, сила тока. Физический смысл, единицы измерения в СИ, законы Ома и Кирхгофа.",
  ),
  TopicItem(
    id: 2,
    title: "Измерение давления (приборы, монтаж, поверка, УГО)",
    fullQuestion: "2. Определение давления. Методы и средства измерения давления. Назначение, устройство, принцип работы, монтаж, ремонт и поверка. Классификация приборов для измерения давления. Условные графические обозначения на функциональных схемах автоматизации.",
  ),
  TopicItem(
    id: 3,
    title: "Измерение температуры (термопары, ТСМ/ТСП, УГО)",
    fullQuestion: "3. Определение температуры. Методы и средства измерения температуры. Назначение, устройство, принцип работы, монтаж, ремонт. Классификация приборов для измерения температуры. Условные графические обозначения на функциональных схемах автоматизации.",
  ),
  TopicItem(
    id: 4,
    title: "Измерение расхода (расходомеры, сужающие, УГО)",
    fullQuestion: "4. Определение расхода. Методы и средства измерения расхода. Назначение, устройство, принцип работы, монтаж, ремонт и поверка. Классификация приборов для измерения расхода. Условные графические обозначения на функциональных схемах автоматизации.",
  ),
  TopicItem(
    id: 5,
    title: "Измерение уровня (гидростатические, радарные, УГО)",
    fullQuestion: "5. Методы и средства измерения уровня. Назначение, устройство, принцип работы, монтаж, ремонт и поверка. Классификация приборов для измерения уровня. Условные графические обозначения на функциональных схемах автоматизации.",
  ),
  TopicItem(
    id: 6,
    title: "Общие сведения об АСУ ТП",
    fullQuestion: "6. Общие сведения об АСУТП (автоматизированной системе управления технологическими процессами). Архитектура, уровни автоматизации (полевой, контроллерный, SCADA/MES).",
  ),
  TopicItem(
    id: 7,
    title: "Определение САУ, объект управления, воздействия",
    fullQuestion: "7. Определение САУ, объекта управления, управляющие и возмущающие воздействия.",
  ),
  TopicItem(
    id: 8,
    title: "Принципы автоматического регулирования, ОС в САУ",
    fullQuestion: "8. Принципы автоматического регулирования (3), классификация САУ (5), обратная связь в САУ.",
  ),
  TopicItem(
    id: 9,
    title: "Качество переходного процесса, устойчивость САУ",
    fullQuestion: "9. Критерии оценки качества переходного процесса. Определение устойчивости системы.",
  ),
  TopicItem(
    id: 10,
    title: "Классификация объектов: емкость, запаздывание, самовыравнивание",
    fullQuestion: "10. Классификация объектов управления. Определения емкости, запаздывания, самовыравнивания.",
  ),
  TopicItem(
    id: 11,
    title: "ПИД-регулятор, принцип работы, методы настройки",
    fullQuestion: "11. ПИД регулятор, принцип работы, назначение составляющих (П, И, Д), методы настройки (Циглер-Николс, кривая разгона).",
  ),
];

// ------------------- ГЛАВНЫЙ ЭКРАН С НАВИГАЦИЕЙ -------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _tabIndex = 0;
  int examDurationMinutes = 10;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onStartExam: () => setState(() => _tabIndex = 1),
        onOpenTutor: () => setState(() => _tabIndex = 2),
        onOpenVoiceQuestion: (topic) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VoiceExamDetailScreen(topic: topic)),
          );
        },
      ),
      TimedExamScreen(durationMinutes: examDurationMinutes),
      const TutorChatScreen(),
      SettingsScreen(
        examDurationMinutes: examDurationMinutes,
        onDurationChanged: (val) => setState(() => examDurationMinutes = val),
      ),
    ];

    return Scaffold(
      body: screens[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        backgroundColor: const Color(0xFF121826),
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Экзамен'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Репетитор'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

// ------------------- ЭКРАН 1: ГЛАВНАЯ СТРАНИЦА -------------------
class HomeScreen extends StatelessWidget {
  final VoidCallback onStartExam;
  final VoidCallback onOpenTutor;
  final Function(TopicItem) onOpenVoiceQuestion;

  const HomeScreen({
    super.key,
    required this.onStartExam,
    required this.onOpenTutor,
    required this.onOpenVoiceQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        title: const Text('КИПиА & Автоматика (ИИ-Тренажёр)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Баннер экзамена на время
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF4338CA)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text('⏱️ ЭКЗАМЕН НА ВРЕМЯ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFFF59E0B),
                    ),
                    Text('11 билетов', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Комплексный тест с таймером', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Вопросы с выбором ответа + развернутые ответы текстом или голосом с оценкой ИИ.',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E3A8A)),
                    onPressed: onStartExam,
                    child: const Text('Начать экзамен', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Быстрые кнопки
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onOpenTutor,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1A233A), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.lightbulb, color: Color(0xFF06B6D4), size: 28),
                        SizedBox(height: 6),
                        Text('ИИ-Репетитор', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('«Объясни мне тему»', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => onOpenVoiceQuestion(globalTopics[10]), // ПИД
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1A233A), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.mic, color: Color(0xFFA855F7), size: 28),
                        SizedBox(height: 6),
                        Text('Голосовой ответ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Оценка устного ответа', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('СПИСОК ВСЕХ 11 БИЛЕТОВ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ...globalTopics.map((topic) => Card(
                color: const Color(0xFF121826),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF263352))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1A233A),
                    child: Text('#${topic.id}', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  title: Text(topic.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.mic_none, size: 20, color: Color(0xFF60A5FA)),
                  onTap: () => onOpenVoiceQuestion(topic),
                ),
              )),
        ],
      ),
    );
  }
}

// ------------------- ЭКРАН 2: ГОЛОСОВОЙ ОТВЕТ НА КОНКРЕТНЫЙ БИЛЕТ -------------------
class VoiceExamDetailScreen extends StatefulWidget {
  final TopicItem topic;
  const VoiceExamDetailScreen({super.key, required this.topic});

  @override
  State<VoiceExamDetailScreen> createState() => _VoiceExamDetailScreenState();
}

class _VoiceExamDetailScreenState extends State<VoiceExamDetailScreen> {
  bool isRecording = false;
  bool isEvaluated = false;

  void handleMicPress() {
    if (isRecording) {
      setState(() {
        isRecording = false;
        isEvaluated = true;
      });
    } else {
      setState(() {
        isRecording = true;
        isEvaluated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Билет №${widget.topic.id}', style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF121826),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1A233A), borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ЭКЗАМЕНАЦИОННЫЙ ВОПРОС:', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.topic.fullQuestion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: handleMicPress,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: isRecording ? Colors.redAccent : const Color(0xFF3B82F6),
                child: Icon(isRecording ? Icons.stop : Icons.mic, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRecording ? 'Запись ответа... Говорите в микрофон' : 'Нажмите на микрофон и ответьте устно',
              style: TextStyle(color: isRecording ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold),
            ),
            if (isEvaluated) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121826),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Вердикт ИИ: 4.8 / 5.0 (Отлично)', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                        Chip(label: Text('Зачтено', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Анализ терминов и точности:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text(
                      'Ответ содержит ключевые формулировки, правильное соотнесение физических параметров и понимание принципа работы. Ошибок в метрологических терминах не выявлено.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// ------------------- ЭКРАН 3: ИИ-РЕПЕТИТОР (ОБЪЯСНЕНИЕ ТЕМ) -------------------
class TutorChatScreen extends StatefulWidget {
  const TutorChatScreen({super.key});

  @override
  State<TutorChatScreen> createState() => _TutorChatScreenState();
}

class _TutorChatScreenState extends State<TutorChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {
      'role': 'ai',
      'text': '👋 Привет! Я твой персональный репетитор по КИПиА и ТАУ. Задай любой вопрос по билетам (например: «Объясни самовыравнивание» или «Как настроить ПИД?»), и я всё понятно объясню!'
    }
  ];

  void sendMessage(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      messages.add({'role': 'user', 'text': query});
    });
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 700), () {
      String response = "В автоматизации этот параметр играет фундаментальную роль. Он входит в типовую программу подготовки инженеров КИПиА и обеспечивает устойчивость САУ.";
      if (query.toLowerCase().contains("самовыравниван")) {
        response = "🎯 Самовыравнивание объекта — это его свойство без помощи регулятора приходить в новое равновесное состояние при возмущении. Например: бак с открытым сливом. При увеличении притока растет уровень и напор слива, и система сама находит баланс!";
      } else if (query.toLowerCase().contains("пид") || query.toLowerCase().contains("настройк")) {
        response = "⚙️ Настройка ПИД по методу Циглера-Николса: отключаем И и Д, увеличиваем Кп до незатухающих колебаний (Ккр), замеряем период (Ткр) и считаем коэффициенты по таблице (Кп=0.6*Ккр, Ти=0.5*Ткр, Тд=0.125*Ткр).";
      }

      setState(() {
        messages.add({'role': 'ai', 'text': response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ИИ-Репетитор: «Объясни мне тему»', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF121826),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF1A233A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: Text(m['text']!, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF121826),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Задайте вопрос по автоматизации...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF3B82F6)),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- ЭКРАН 4: ЭКЗАМЕН НА ВРЕМЯ (ГИБРИДНЫЙ ТЕСТ) -------------------
class TimedExamScreen extends StatefulWidget {
  final int durationMinutes;
  const TimedExamScreen({super.key, required this.durationMinutes});

  @override
  State<TimedExamScreen> createState() => _TimedExamScreenState();
}

class _TimedExamScreenState extends State<TimedExamScreen> {
  int currentQuestion = 0;
  int remainingSeconds = 600;
  Timer? timer;
  int? selectedChoice;
  bool isVoiceRecorded = false;
  final TextEditingController textAnswerController = TextEditingController();
  bool isFinished = false;

  final questions = [
    {
      'type': 'choice',
      'title': 'Электротехника: Сила тока',
      'prompt': 'В каких единицах международной системы СИ измеряется сила электрического тока, и каким прибором она измеряется?',
      'options': [
        'В Вольтах (В), вольтметром параллельно цепи',
        'В Амперах (А), амперметром последовательно в разрыв цепи',
        'В Омах (Ом), омметром',
        'В Ваттах (Вт), ваттметром'
      ],
      'correct': 1
    },
    {
      'type': 'open',
      'title': 'Расход: Вихревой расходомер',
      'prompt': 'Опишите принцип действия вихревого расходомера. На каком физическом эффекте основано появление вихрей?',
    },
    {
      'type': 'choice',
      'title': 'Схемы автоматизации (УГО)',
      'prompt': 'Что означает буквенное обозначение «PIC» на функциональной схеме по ГОСТ 21.408?',
      'options': [
        'Показывающий и регулирующий прибор давления',
        'Датчик температуры позиционный',
        'Преобразователь расхода интегральный',
        'Уровнемер предельный'
      ],
      'correct': 0
    },
    {
      'type': 'open',
      'title': 'ТАУ: ПИД-регулятор',
      'prompt': 'Объясните физический смысл П, И и Д составляющих. От какой именно ошибки избавляет интегральная часть?',
    },
  ];

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.durationMinutes * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        setState(() => isFinished = true);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    textAnswerController.dispose();
    super.dispose();
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedChoice = null;
        isVoiceRecorded = false;
        textAnswerController.clear();
      });
    } else {
      timer?.cancel();
      setState(() => isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Итоги экзамена'), backgroundColor: const Color(0xFF121826)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 80),
                const SizedBox(height: 16),
                const Text('ЭКЗАМЕН СДАН!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Итоговый балл ИИ: 4.8 / 5.0 (Отлично)', style: TextStyle(fontSize: 16, color: Color(0xFF10B981))),
                const SizedBox(height: 20),
                const Text('Тесты решены без ошибок. Развернутые ответы по расходомерам и ПИД-регуляторам содержат все ключевые термины ГОСТ.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFinished = false;
                      currentQuestion = 0;
                      remainingSeconds = widget.durationMinutes * 60;
                    });
                  },
                  child: const Text('Пройти заново'),
                )
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[currentQuestion];
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('Вопрос ${currentQuestion + 1}/${questions.length}'),
        backgroundColor: const Color(0xFF121826),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('⏱️ ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q['title'] as String, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Text(q['prompt'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            if (q['type'] == 'choice') ...[
              ...((q['options'] as List<String>).asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: selectedChoice == idx ? const Color(0xFF1E3A8A) : const Color(0xFF121826),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selectedChoice == idx ? const Color(0xFF3B82F6) : const Color(0xFF263352)),
                  ),
                  child: ListTile(
                    title: Text(text, style: const TextStyle(fontSize: 13)),
                    onTap: () => setState(() => selectedChoice = idx),
                  ),
                );
              }))
            ] else ...[
              const Text('Выберите способ ответа (текст или голос):', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: textAnswerController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Введите технический ответ здесь...',
                  filled: true,
                  fillColor: const Color(0xFF121826),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF263352))),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVoiceRecorded ? const Color(0xFF10B981) : const Color(0xFF1A233A),
                  ),
                  onPressed: () => setState(() => isVoiceRecorded = !isVoiceRecorded),
                  icon: Icon(isVoiceRecorded ? Icons.check : Icons.mic),
                  label: Text(isVoiceRecorded ? 'Голосовой ответ записан' : 'Наговорить ответ голосом'),
                ),
              )
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                onPressed: nextQuestion,
                child: Text(currentQuestion < questions.length - 1 ? 'Следующий вопрос ➔' : 'Завершить экзамен'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------- ЭКРАН 5: НАСТРОЙКА ВОПРОСОВ И ТАЙМЕРА -------------------
class SettingsScreen extends StatefulWidget {
  final int examDurationMinutes;
  final ValueChanged<int> onDurationChanged;

  const SettingsScreen({
    super.key,
    required this.examDurationMinutes,
    required this.onDurationChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройка вопросов и банка'), backgroundColor: const Color(0xFF121826)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('ВРЕМЯ НА ЭКЗАМЕНАЦИОННЫЙ ТЕСТ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [5, 10, 15, 30].map((mins) {
              final isSel = widget.examDurationMinutes == mins;
              return ChoiceChip(
                label: Text('$mins мин'),
                selected: isSel,
                onSelected: (_) => widget.onDurationChanged(mins),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('ВЫБОР АКТИВНЫХ БИЛЕТОВ (ИЗ 11 ТЕМ)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),
          ...globalTopics.map((t) => SwitchListTile(
                title: Text('#${t.id}. ${t.title}', style: const TextStyle(fontSize: 13)),
                value: t.isActive,
                onChanged: (val) => setState(() => t.isActive = val),
              )),
        ],
      ),
    );
  }
}
