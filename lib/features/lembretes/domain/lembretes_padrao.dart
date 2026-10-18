import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';

/// Os lembretes que vêm no app: a Hora da Ave-Maria, ao meio-dia e às 18h.
///
/// Para mudar horário ou textos, é só editar aqui.
/// Para criar um novo lembrete, acrescente na lista com um [id] novo (nunca
/// reaproveite um id já usado).
class LembretesPadrao {
  static const List<Lembrete> todos = [meioDia, entardecer];

  static const Lembrete meioDia = Lembrete(
    id: 1,
    hora: 12,
    minuto: 0,
    titulo: 'Hora da Ave-Maria',
    descricao: 'Ao meio-dia, como faziam os trabalhadores de antigamente.',
    mensagens: [
      'É meio-dia: Hora da Ave-Maria. Como faziam os trabalhadores de '
          'antigamente, pare um instante e reze uma Ave-Maria. 🙏',
      'Antigamente o sino tocava ao meio-dia e o trabalho parava para saudar '
          'Maria. Que tal fazer essa pausa agora?',
      'No campo e na cidade, tudo silenciava ao meio-dia para rezar. Reze uma '
          'Ave-Maria e leve Nossa Senhora para o seu dia.',
      'Hora da Ave-Maria! Algumas rádios antigas ainda interrompem a '
          'programação neste horário. Una-se a essa tradição.',
      'Meio-dia. Uma pausa pequena e uma oração simples: Ave-Maria, cheia de '
          'graça, o Senhor é convosco…',
      'Maria também trabalhou e cuidou da casa. Ofereça a ela o seu dia e '
          'reze uma Ave-Maria.',
      'Ao meio-dia a Igreja recorda que o Anjo do Senhor anunciou a Maria. '
          'Faça uma pausa e reze com ela.',
    ],
  );

  static const Lembrete entardecer = Lembrete(
    id: 2,
    hora: 18,
    minuto: 0,
    titulo: 'Hora da Ave-Maria',
    descricao: 'Ao entardecer, no fim do dia de trabalho.',
    mensagens: [
      'São 18 horas: Hora da Ave-Maria. No fim do dia de trabalho, os antigos '
          'paravam para rezar. Faça essa pausa. 🙏',
      'O sino do entardecer chamava todos à oração. Reze uma Ave-Maria e '
          'entregue o seu dia a Maria.',
      'Hora da Ave-Maria! Há rádios que ainda interrompem a programação às '
          '18h para rezar. Reze com elas.',
      'O dia está terminando. Que tal agradecer a Deus com uma Ave-Maria?',
      'Ao entardecer, Maria acolhe o seu cansaço. Reze uma Ave-Maria e, se '
          'puder, o terço das Sete Alegrias.',
      '18 horas. Hora de parar um instante, como faziam nossos avós, e saudar '
          'Nossa Senhora.',
      'Termine o dia com Maria: uma Ave-Maria agora, ou o terço inteiro, se '
          'tiver um tempinho.',
    ],
  );
}
