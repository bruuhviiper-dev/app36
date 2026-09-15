/// Pergunta/desafio do casal do dia — determinística (offline), muda a cada dia.
/// Traduzida: passe o código do idioma ('pt' | 'en' | 'es').
class CoupleQuestions {
  CoupleQuestions._();

  static const Map<String, List<String>> _byLang = {
    'pt': [
      'Qual foi o momento que você soube que me amava?',
      'Se pudéssemos viajar pra qualquer lugar agora, pra onde iríamos?',
      'Qual é a sua lembrança favorita da gente?',
      'O que eu faço que sempre te faz sorrir?',
      'Como você imagina a gente daqui a 10 anos?',
      'Qual música te lembra de nós dois?',
      'Qual foi o nosso melhor encontro até hoje?',
      'O que você mais admira em mim?',
      'Se fôssemos morar juntos hoje, o que não poderia faltar em casa?',
      'Qual pequeno hábito meu você acha fofo?',
      'Qual sonho você quer realizar comigo?',
      'Qual foi a primeira coisa que te chamou atenção em mim?',
      'Que tradição nova você quer criar pra gente?',
      'Qual comida te lembra de um momento nosso?',
      'O que te faz sentir mais amado(a) por mim?',
      'Se a gente ganhasse um dia livre juntos, o que faríamos?',
      'Qual apelido carinhoso você mais gosta que eu te chame?',
      'Qual foi a maior surpresa boa que já te fiz?',
      'O que você quer aprender ou fazer comigo esse ano?',
      'Descreva a gente em três palavras.',
      'Qual foi a risada mais gostosa que demos juntos?',
      'O que você mais sente falta quando estamos longe?',
    ],
    'en': [
      'When was the moment you knew you loved me?',
      'If we could travel anywhere right now, where would we go?',
      'What is your favorite memory of us?',
      'What do I do that always makes you smile?',
      'How do you picture us 10 years from now?',
      'What song reminds you of the two of us?',
      'What has been our best date so far?',
      'What do you admire most about me?',
      "If we moved in together today, what couldn't be missing at home?",
      'What little habit of mine do you find cute?',
      'What dream do you want to make come true with me?',
      'What was the first thing that caught your eye about me?',
      'What new tradition do you want to create for us?',
      'What food reminds you of a moment of ours?',
      'What makes you feel most loved by me?',
      'If we got a free day together, what would we do?',
      'What nickname do you like me to call you the most?',
      'What was the best surprise I ever gave you?',
      'What do you want to learn or do with me this year?',
      'Describe us in three words.',
      'What was the best laugh we shared together?',
      'What do you miss most when we are apart?',
    ],
    'es': [
      '¿Cuál fue el momento en que supiste que me amabas?',
      'Si pudiéramos viajar a cualquier lugar ahora, ¿adónde iríamos?',
      '¿Cuál es tu recuerdo favorito de nosotros?',
      '¿Qué hago que siempre te hace sonreír?',
      '¿Cómo nos imaginas dentro de 10 años?',
      '¿Qué canción te recuerda a los dos?',
      '¿Cuál ha sido nuestra mejor cita hasta hoy?',
      '¿Qué es lo que más admiras de mí?',
      'Si viviéramos juntos hoy, ¿qué no podría faltar en casa?',
      '¿Qué pequeña manía mía te parece tierna?',
      '¿Qué sueño quieres cumplir conmigo?',
      '¿Qué fue lo primero que te llamó la atención de mí?',
      '¿Qué nueva tradición quieres crear para nosotros?',
      '¿Qué comida te recuerda a un momento nuestro?',
      '¿Qué te hace sentir más amado(a) por mí?',
      'Si tuviéramos un día libre juntos, ¿qué haríamos?',
      '¿Qué apodo cariñoso te gusta más que te diga?',
      '¿Cuál fue la mejor sorpresa que te di?',
      '¿Qué quieres aprender o hacer conmigo este año?',
      'Descríbenos en tres palabras.',
      '¿Cuál fue la mejor risa que compartimos juntos?',
      '¿Qué extrañas más cuando estamos lejos?',
    ],
  };

  static String ofDay(String lang, [DateTime? date]) {
    final list = _byLang[lang] ?? _byLang['en']!;
    final d = date ?? DateTime.now();
    final idx = DateTime(d.year, d.month, d.day)
            .difference(DateTime(2020, 1, 1))
            .inDays
            .abs() %
        list.length;
    return list[idx];
  }
}
