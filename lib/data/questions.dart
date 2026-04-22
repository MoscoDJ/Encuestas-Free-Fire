import '../models/question.dart';

const String sectionAboutYou = 'Sobre ti y Free Fire';
const String sectionFeeling = 'Sentimiento general sobre la Casa del Yeti';
const String sectionConnection = 'Conexión con Free Fire y la comunidad';
const String sectionBrand = 'Recomendación y percepción de marca';

const List<Question> questions = [
  Question(
    id: 'q1',
    section: sectionAboutYou,
    text: '¿Juegas Free Fire actualmente?',
    type: QuestionType.singleChoice,
    options: [
      'Juego casi todos los días',
      'Juego 1–2 veces por semana',
      'Jugué antes, pero ahora casi no juego',
      'Nunca he jugado Free Fire',
    ],
  ),
  Question(
    id: 'q2',
    section: sectionAboutYou,
    text: '¿Es la primera vez que vas a una activación en vivo de Free Fire?',
    type: QuestionType.singleChoice,
    options: ['Sí', 'No'],
  ),
  Question(
    id: 'q3',
    section: sectionFeeling,
    text: 'En general, ¿cómo te hizo sentir la Casa del Yeti?',
    type: QuestionType.scale1to5,
    options: ['Muy mal', 'Mal', 'Neutral', 'Bien', 'Increíble'],
    lowLabel: 'Muy mal',
    highLabel: 'Increíble',
  ),
  Question(
    id: 'q4',
    section: sectionFeeling,
    text: '¿Qué emociones sentiste más durante la activación?',
    type: QuestionType.multiChoice,
    options: [
      'Alegría',
      'Emoción',
      'Sorpresa',
      'Nostalgia',
      'Relajación',
      'Indiferencia',
      'Frustración',
      'Confusión',
    ],
  ),
  Question(
    id: 'q5',
    section: sectionFeeling,
    text: '¿Qué tan especial/mágica te pareció la experiencia?',
    type: QuestionType.scale1to5,
    options: ['Nada especial', 'Poco especial', 'Normal', 'Muy especial', 'Súper mágica'],
    lowLabel: 'Nada especial',
    highLabel: 'Súper mágica',
  ),
  Question(
    id: 'q6',
    section: sectionConnection,
    text: 'Después de esta activación, tengo más ganas de jugar Free Fire o volver al juego.',
    type: QuestionType.singleChoice,
    options: [
      'Mucho menos ganas',
      'Menos ganas',
      'Igual que antes',
      'Más ganas',
      'Mucho más ganas',
    ],
  ),
  Question(
    id: 'q7',
    section: sectionBrand,
    text: '¿Recomendarías una activación como la Casa del Yeti a un amigo o amiga?',
    type: QuestionType.nps0to10,
    lowLabel: 'Nada probable',
    highLabel: 'Muy probable',
  ),
  Question(
    id: 'q8',
    section: sectionBrand,
    text: 'Si pudieras cambiar o mejorar algo de la experiencia, ¿qué sería?',
    type: QuestionType.openText,
  ),
];
