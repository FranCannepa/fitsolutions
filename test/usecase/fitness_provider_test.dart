import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

void main() {
  FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
  MockSharedPrefsHelper mockSharedPrefs = MockSharedPrefsHelper();

  TestWidgetsFlutterBinding.ensureInitialized();

  FitnessProvider provider = FitnessProvider(fakeFirestore, mockSharedPrefs);
  group('Funcionalidad Rutina', () {
    test('Get Rutinas', () async {
      const userId = 'userId';
      await fakeFirestore.collection('plan').doc('planId').set({
        'name': 'Plan 1',
        'description': 'This is a sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '180', 'max': '200'},
        'ownerId': userId
      });
      await fakeFirestore
          .collection('plan')
          .doc('planId')
          .collection('week')
          .doc('weekId')
          .set({'number': 1});
      await fakeFirestore
          .collection('plan')
          .doc('planId')
          .collection('week')
          .doc('weekId')
          .collection('ejercicio')
          .doc('exerciseId')
          .set({
        'nombre': 'Push-up',
        'descripcion': 'An exercise for upper body strength',
        'ejecucion': '30',
        'serie': 3,
        'pausa': '60',
        'repeticion': 15,
        'carga': 0,
        'dia': 'Monday'
      });
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);
      final planes = await provider.getPlanesList();

      expect(planes, isA<List<Plan>>());
      expect(planes.length, 1);
      expect(planes[0].planId, 'planId');
      expect(planes[0].name, 'Plan 1');
      expect(planes[0].description, 'This is a sample plan');
      expect(planes[0].weight, {'min': '180', 'max': '200'});
      expect(planes[0].height, {'min': '180', 'max': '200'});
      expect(planes[0].weeks.length, 1);
      expect(planes[0].weeks[0].id, 'weekId');
      expect(planes[0].weeks[0].numero, 1);
      expect(planes[0].weeks[0].ejercicios.length, 1);
      expect(planes[0].weeks[0].ejercicios[0].id, 'exerciseId');
      expect(planes[0].weeks[0].ejercicios[0].nombre, 'Push-up');
      expect(planes[0].weeks[0].ejercicios[0].descripcion,
          'An exercise for upper body strength');
      expect(planes[0].weeks[0].ejercicios[0].tipo, 'Type');
      expect(planes[0].weeks[0].ejercicios[0].duracion, '30');
      expect(planes[0].weeks[0].ejercicios[0].series, 3);
      expect(planes[0].weeks[0].ejercicios[0].repeticiones, 15);
      expect(planes[0].weeks[0].ejercicios[0].pausas, '60');
      expect(planes[0].weeks[0].ejercicios[0].carga, 0);
      expect(planes[0].weeks[0].ejercicios[0].dia, 'Monday');
    });
    test('Single Plan get', () async {
      await fakeFirestore.collection('plan').doc('planId').set({
        'name': 'Plan 1',
        'description': 'This is a sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '180', 'max': '200'},
      });
      await fakeFirestore
          .collection('plan')
          .doc('planId')
          .collection('week')
          .doc('weekId')
          .set({'number': 1});
      await fakeFirestore
          .collection('plan')
          .doc('planId')
          .collection('week')
          .doc('weekId')
          .collection('ejercicio')
          .doc('exerciseId')
          .set({
        'nombre': 'Push-up',
        'descripcion': 'An exercise for upper body strength',
        'ejecucion': '30',
        'serie': 3,
        'pausa': '60',
        'repeticion': 15,
        'carga': 0,
        'dia': 'Monday'
      });

      Plan? plan = await provider.getPlanById('planId');

      expect(plan, isA<Plan>());
      expect(plan!.planId, 'planId');
      expect(plan.name, 'Plan 1');
      expect(plan.description, 'This is a sample plan');
      expect(plan.weight, {'min': '180', 'max': '200'});
      expect(plan.height, {'min': '180', 'max': '200'});
      expect(plan.weeks.length, 1);
      expect(plan.weeks[0].id, 'weekId');
      expect(plan.weeks[0].numero, 1);
      expect(plan.weeks[0].ejercicios.length, 1);
      expect(plan.weeks[0].ejercicios[0].id, 'exerciseId');
      expect(plan.weeks[0].ejercicios[0].nombre, 'Push-up');
      expect(plan.weeks[0].ejercicios[0].descripcion,
          'An exercise for upper body strength');
      expect(plan.weeks[0].ejercicios[0].tipo, 'Type');
      expect(plan.weeks[0].ejercicios[0].duracion, '30');
      expect(plan.weeks[0].ejercicios[0].series, 3);
      expect(plan.weeks[0].ejercicios[0].repeticiones, 15);
      expect(plan.weeks[0].ejercicios[0].pausas, '60');
      expect(plan.weeks[0].ejercicios[0].carga, 0);
      expect(plan.weeks[0].ejercicios[0].dia, 'Monday');
    });

    test('Add plan', () async {

      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      final Plan addedPlan = await provider.addPlan(
        'Plan 1',
        'This is a sample plan',
        {'min': '180', 'max': '200'},
        {'min': '180', 'max': '200'},
      );


      expect(addedPlan, isA<Plan>());
      expect(addedPlan.name, 'Plan 1');
      expect(addedPlan.description, 'This is a sample plan');
      expect(addedPlan.weight, {'min': '180', 'max': '200'});
      expect(addedPlan.height, {'min': '180', 'max': '200'});

      final docSnapshot =
          await fakeFirestore.collection('plan').doc(addedPlan.planId).get();
      final data = docSnapshot.data() as Map<String, dynamic>;

      expect(data['name'], 'Plan 1');
      expect(data['description'], 'This is a sample plan');
      expect(data['weight'], {'min': '180', 'max': '200'});
      expect(data['height'], {'min': '180', 'max': '200'});
    });

    test('deletePlan deletes a plan and its associated weeks', () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      final planDoc = await fakeFirestore.collection('plan').add({
        'name': 'Plan 1',
        'description': 'This is a sample plan',
        'weight': {'min': '70', 'max': '75'}, // Corrected structure
        'height': {'min': '180', 'max': '200'}, // Corrected structure
      });
      await fakeFirestore
          .collection('plan')
          .doc(planDoc.id)
          .collection('week')
          .doc('weekId')
          .set({'number': 1});


      expect(
          (await fakeFirestore.collection('plan').doc(planDoc.id).get()).exists,
          isTrue);
      expect(
          (await fakeFirestore
                  .collection('plan')
                  .doc(planDoc.id)
                  .collection('week')
                  .doc('weekId')
                  .get())
              .exists,
          isTrue);

      await provider.deletePlan(planDoc.id);


      expect(
          (await fakeFirestore.collection('plan').doc(planDoc.id).get()).exists,
          isFalse);
      expect(
          (await fakeFirestore
                  .collection('plan')
                  .doc(planDoc.id)
                  .collection('week')
                  .doc('weekId')
                  .get())
              .exists,
          isFalse);
    });
    test('updatePlan updates a plan with new values', () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      final planDoc = await fakeFirestore.collection('plan').add({
        'name': 'Original Plan',
        'description': 'Original description',
        'weight': {'min': '70', 'max': '75'},
        'height': {'min': '180', 'max': '200'},
      });


      const newName = 'Updated Plan';
      const newDescription = 'Updated description';
      final newWeight = {'min': '75', 'max': '80'};
      final newHeight = {'min': '185', 'max': '190'};


      await provider.updatePlan(
          planDoc.id, newName, newDescription, newWeight, newHeight);


      final updatedPlanDoc =
          await fakeFirestore.collection('plan').doc(planDoc.id).get();


      expect(updatedPlanDoc.data()!['name'], equals(newName));
      expect(updatedPlanDoc.data()!['description'], equals(newDescription));
      expect(updatedPlanDoc.data()!['weight'], equals(newWeight));
      expect(updatedPlanDoc.data()!['height'], equals(newHeight));
    });
  });

  group('Funcionalidad Ejercicios', () {
    test('Add week', () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );


      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });


      await provider.addWeek(1, plan);


      final weekSnapshot = await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .get();
      expect(weekSnapshot.docs.length, equals(1));
      expect(weekSnapshot.docs.first.data()['number'], equals(1));


      expect(plan.weeks.length, equals(1));
      expect(plan.weeks.first.numero, equals(1));
    });

    test('addEjercicioASemana adds an exercise to a specific week in the plan',
        () async {

      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );


      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });


      const weekNumber = 'week1';
      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });


      const name = 'Push Up';
      const descripcion = 'An upper body exercise';
      const serie = 3;
      const repeticion = 15;
      const carga = null;
      const ejecucion = '60'; // Changed from int to String
      const pausa = '30'; // Changed from int to String
      const dia = 'Monday';


      await provider.addEjercicioASemana(plan, weekNumber, name, descripcion,
          serie, repeticion, carga, ejecucion, pausa, dia);


      final exerciseSnapshot = await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .collection('ejercicio')
          .get();
      expect(exerciseSnapshot.docs.length, equals(1));
      expect(exerciseSnapshot.docs.first.data()['nombre'], equals(name));
      expect(exerciseSnapshot.docs.first.data()['descripcion'],
          equals(descripcion));
      expect(exerciseSnapshot.docs.first.data()['serie'], equals(serie));
      expect(
          exerciseSnapshot.docs.first.data()['repeticion'], equals(repeticion));
      expect(exerciseSnapshot.docs.first.data()['carga'], equals(carga));
      expect(
          exerciseSnapshot.docs.first.data()['ejecucion'], equals(ejecucion));
      expect(exerciseSnapshot.docs.first.data()['pausa'], equals(pausa));
      expect(exerciseSnapshot.docs.first.data()['dia'], equals(dia));
    });

    test(
        'getEjerciciosDelDiaList retrieves exercises for a specific day within a week',
        () async {

      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );


      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });


      const weekNumber = 'week1';
      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });


      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .collection('ejercicio')
          .add({
        'nombre': 'Push Up',
        'descripcion': 'An upper body exercise',
        'serie': 3,
        'repeticion': 15,
        'carga': null,
        'ejecucion': '60',
        'pausa': '30',
        'dia': 'Monday',
      });
      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .collection('ejercicio')
          .add({
        'nombre': 'Squats',
        'descripcion': 'A lower body exercise',
        'serie': 3,
        'repeticion': 15,
        'carga': null,
        'ejecucion': '60',
        'pausa': '30',
        'dia': 'Tuesday',
      });


      final exercisesMonday =
          await provider.getEjerciciosDelDiaList(plan, weekNumber, 'Monday');


      expect(exercisesMonday.length, equals(2));
      expect(exercisesMonday.first.nombre, equals('Push Up'));
    });
    test(
        'addUsuarioARutina adds users to the subscripto subcollection and assigns the plan to each user',
        () async {

      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);
      const planId = 'plan1';


      final weight = {'min': '180', 'max': '200'};
      final height = {'min': '150', 'max': '180'};


      final users = [
        UsuarioBasico(
            docId: 'user1',
            email: 'user1@example.com',
            nombreCompleto: 'User One',
            telefono: '1234567890',
            fcmToken: '123',
            rutina: 'fake_rutina',
            fechaNacimiento: '1998-01-09'),
        UsuarioBasico(
            docId: 'user2',
            email: 'user2@example.com',
            nombreCompleto: 'User Two',
            telefono: '0987654321',
            fcmToken: '123',
            rutina: 'fake_rutina',
            fechaNacimiento: '1998-01-09'),
      ];


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': weight,
        'height': height,
      });


      for (final user in users) {
        await fakeFirestore.collection('usuario').doc(user.docId).set({
          'email': user.email,
          'nombreCompleto': user.nombreCompleto,
          'telefono': user.telefono,
          'peso': user.peso,
          'altura': user.altura,
        });
      }


      await provider.addUsuarioARutina(planId, users);


      final subscriptoSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('subscripto')
          .get();
      expect(subscriptoSnapshot.docs.length, equals(2));

      for (final user in users) {
        final userDoc =
            subscriptoSnapshot.docs.firstWhere((doc) => doc.id == user.docId);
        expect(userDoc.data()['email'], equals(user.email));
        expect(userDoc.data()['nombreCompleto'], equals(user.nombreCompleto));
      }


      for (final user in users) {
        final userSnapshot =
            await fakeFirestore.collection('usuario').doc(user.docId).get();
        expect(userSnapshot.data()?['rutina'], equals(planId));
      }
    });
    test(
        'updateEjercicio updates an ejercicio document within a specific week in a plan',
        () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      const planId = 'plan1';


      const weekNumber = 'week1';


      const ejercicioId = 'ejercicio1';


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekNumber)
          .collection('ejercicio')
          .doc(ejercicioId)
          .set({
        'nombre': 'Old Name',
        'descripcion': 'Old Description',
        'serie': 3,
        'repeticion': 10,
        'carga': 20,
        'ejecucion': '30 min',
        'pausa': '1 min',
      });


      const newName = 'New Name';
      const newDescripcion = 'New Description';
      const newSerie = 4;
      const newRepeticion = 12;
      const newCarga = 25;
      const newEjecucion = '35 min';
      const newPausa = '2 min';


      await provider.updateEjercicio(
        Plan(
          planId: planId,
          name: 'Sample Plan',
          description: 'A sample plan',
          weight: {'min': '180', 'max': '200'},
          height: {'min': '150', 'max': '180'},
          weeks: [],
        ),
        ejercicioId,
        weekNumber,
        newName,
        newDescripcion,
        newSerie,
        newRepeticion,
        newCarga,
        newEjecucion,
        newPausa,
      );


      final ejercicioSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekNumber)
          .collection('ejercicio')
          .doc(ejercicioId)
          .get();
      final ejercicioData = ejercicioSnapshot.data();

      expect(ejercicioData?['nombre'], equals(newName));
      expect(ejercicioData?['descripcion'], equals(newDescripcion));
      expect(ejercicioData?['serie'], equals(newSerie));
      expect(ejercicioData?['repeticion'], equals(newRepeticion));
      expect(ejercicioData?['carga'], equals(newCarga));
      expect(ejercicioData?['ejecucion'], equals(newEjecucion));
      expect(ejercicioData?['pausa'], equals(newPausa));
    });
    test('deleteExercisesfromWeek deletes all exercises in a specific week',
        () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      const planId = 'plan1';
      const weekId = 'week1';


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .set({
        'number': 1,
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .collection('ejercicio')
          .add({
        'nombre': 'Ejercicio 1',
        'descripcion': 'Descripcion 1',
        'serie': 3,
        'repeticion': 10,
        'carga': 20,
        'ejecucion': '30 min',
        'pausa': '1 min',
      });
      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .collection('ejercicio')
          .add({
        'nombre': 'Ejercicio 2',
        'descripcion': 'Descripcion 2',
        'serie': 3,
        'repeticion': 12,
        'carga': 25,
        'ejecucion': '35 min',
        'pausa': '2 min',
      });


      await provider.deleteExercisesfromWeek(planId, weekId);


      final ejercicioSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .collection('ejercicio')
          .get();
      expect(ejercicioSnapshot.docs.isEmpty, isTrue);
    });
    test('deleteWeeksFromPlan deletes all weeks in a specific plan', () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      const planId = 'plan1';


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .add({
        'number': 1,
      });
      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .add({
        'number': 2,
      });


      await provider.deleteWeeksFromPlan(planId);


      final weekSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .get();
      expect(weekSnapshot.docs.isEmpty, isTrue);
    });
    test('deleteEjercicio deletes a specific exercise in a specific week',
        () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      const planId = 'plan1';
      const weekId = 'week1';
      const ejercicioId = 'ejercicio1';


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .set({
        'number': 1,
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .collection('ejercicio')
          .doc(ejercicioId)
          .set({
        'nombre': 'Ejercicio 1',
        'descripcion': 'Descripcion 1',
        'serie': 3,
        'repeticion': 10,
        'carga': 20,
        'ejecucion': '30 min',
        'pausa': '1 min',
        'dia': 'Lunes',
      });


      final plan = Plan(
        planId: planId,
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '180', 'max': '200'},
        height: {'min': '150', 'max': '180'},
        weeks: [],
      );


      await provider.deleteEjercicio(plan, weekId, ejercicioId);


      final ejercicioSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .collection('ejercicio')
          .doc(ejercicioId)
          .get();
      expect(ejercicioSnapshot.exists, isFalse);
    });

    test(
        'deleteWeek deletes the last week and its exercises from a specific plan',
        () async {
      const userId = 'userId';
      when(mockSharedPrefs.getUserId()).thenAnswer((_) async => userId);

      const planId = 'plan1';
      const weekId1 = 'week1';
      const weekId2 = 'week2';
      const ejercicioId1 = 'ejercicio1';
      const ejercicioId2 = 'ejercicio2';


      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId1)
          .set({
        'number': 1,
      });
      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .set({
        'number': 2,
      });


      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .collection('ejercicio')
          .doc(ejercicioId1)
          .set({
        'nombre': 'Ejercicio 1',
        'descripcion': 'Descripcion 1',
        'serie': 3,
        'repeticion': 10,
        'carga': 20,
        'ejecucion': '30 min',
        'pausa': '1 min',
        'dia': 'Lunes',
      });

      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .collection('ejercicio')
          .doc(ejercicioId2)
          .set({
        'nombre': 'Ejercicio 2',
        'descripcion': 'Descripcion 2',
        'serie': 4,
        'repeticion': 12,
        'carga': 25,
        'ejecucion': '45 min',
        'pausa': '2 min',
        'dia': 'Martes',
      });


      final plan = Plan(
        planId: planId,
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '180', 'max': '200'},
        height: {'min': '150', 'max': '180'},
        weeks: [
          Week.fromDocument(weekId1, {'number': 1}, []),
          Week.fromDocument(weekId2, {'number': 2}, []),
        ],
      );


      await provider.deleteWeek(plan);


      final weekSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .get();
      expect(weekSnapshot.exists, isFalse);

      final ejercicioSnapshot1 = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .collection('ejercicio')
          .doc(ejercicioId1)
          .get();
      expect(ejercicioSnapshot1.exists, isFalse);

      final ejercicioSnapshot2 = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId2)
          .collection('ejercicio')
          .doc(ejercicioId2)
          .get();
      expect(ejercicioSnapshot2.exists, isFalse);
    });
  });
}
