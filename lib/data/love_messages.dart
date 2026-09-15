/// Mensagem de amor do dia — determinística (offline), muda a cada dia.
/// Traduzida: passe o código do idioma ('pt' | 'en' | 'es').
class LoveMessages {
  LoveMessages._();

  static const Map<String, List<String>> _byLang = {
    'pt': [
      'Cada dia ao seu lado é o meu lugar favorito no mundo.',
      'Você é a melhor parte de todos os meus dias. 💕',
      'Com você, o tempo passa e o amor só aumenta.',
      'Obrigado(a) por escolher me amar todos os dias.',
      'Você é o meu "para sempre" que eu escolhi.',
      'Ao seu lado, até o dia mais comum vira especial.',
      'Meu coração sorri toda vez que penso em você.',
      'Se eu pudesse, viveria esse amor mil vezes de novo.',
      'Você é o meu abraço favorito e o meu melhor lar.',
      'Nosso amor é a história mais linda que eu já vivi.',
      'Do seu lado eu encontrei a paz e a bagunça mais gostosa.',
      'Te amar é fácil; te amar todo dia é a minha alegria.',
      'Você faz o meu mundo mais bonito só por existir.',
      'Cada "bom dia" seu vale mais que qualquer coisa.',
      'Eu escolho você, hoje e em todos os amanhãs.',
      'Nosso "nós" é o meu pedacinho de céu aqui na terra.',
    ],
    'en': [
      'Every day by your side is my favorite place in the world.',
      'You are the best part of all my days. 💕',
      'With you, time passes and love only grows.',
      'Thank you for choosing to love me every day.',
      'You are the "forever" that I chose.',
      'By your side, even the most ordinary day feels special.',
      'My heart smiles every time I think of you.',
      'If I could, I would live this love a thousand times over.',
      'You are my favorite hug and my best home.',
      'Our love is the most beautiful story I have ever lived.',
      'By your side I found peace and the sweetest chaos.',
      'Loving you is easy; loving you every day is my joy.',
      'You make my world more beautiful just by existing.',
      'Every "good morning" from you is worth more than anything.',
      'I choose you, today and in every tomorrow.',
      'Our "us" is my little piece of heaven on earth.',
    ],
    'es': [
      'Cada día a tu lado es mi lugar favorito del mundo.',
      'Eres la mejor parte de todos mis días. 💕',
      'Contigo, el tiempo pasa y el amor solo crece.',
      'Gracias por elegir amarme cada día.',
      'Eres el "para siempre" que yo elegí.',
      'A tu lado, hasta el día más común se vuelve especial.',
      'Mi corazón sonríe cada vez que pienso en ti.',
      'Si pudiera, viviría este amor mil veces más.',
      'Eres mi abrazo favorito y mi mejor hogar.',
      'Nuestro amor es la historia más linda que he vivido.',
      'A tu lado encontré la paz y el desorden más dulce.',
      'Amarte es fácil; amarte cada día es mi alegría.',
      'Haces mi mundo más bonito solo con existir.',
      'Cada "buenos días" tuyo vale más que cualquier cosa.',
      'Te elijo a ti, hoy y en todos los mañanas.',
      'Nuestro "nosotros" es mi pedacito de cielo en la tierra.',
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
