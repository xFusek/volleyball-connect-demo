import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/matches/data/models/match_model.dart';
import 'package:social_app/features/matches/presentation/widgets/match_card.dart';

void main() {
  final dummyMatch = MatchModel(
    id: '123',
    ownerId: 'user_1',
    header: 'Siatkówka Plażowa 2v2',
    location: 'Warszawa Mokotów',
    description: 'Szukamy 1 osoby do składu na popołudnie.',
    maxParticipants: 4,
    participants: ['user1', 'user2'],
    tags: ['Beach', 'Intermediate'],
  );

  testWidgets('MatchCard renders match details correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => SingleChildScrollView(
              child: MatchCard(
                match: dummyMatch,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Siatkówka Plażowa 2v2'), findsOneWidget);
    expect(
      find.text('Szukamy 1 osoby do składu na popołudnie.'),
      findsOneWidget,
    );
    expect(find.text('Beach'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.byType(MatchCard), findsOneWidget);
  });
}