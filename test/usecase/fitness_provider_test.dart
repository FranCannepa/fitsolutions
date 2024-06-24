import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';



void main() {
  FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();


 TestWidgetsFlutterBinding.ensureInitialized();
  final MockFlutterLocalNotificationsPlugin mock = MockFlutterLocalNotificationsPlugin();

FitnessProvider provider = FitnessProvider(fakeFirestore,NotificationService(mock));
  group('Funcionalidad Rutina', () {
    test('Get Rutinas', () async {
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

      final planes = await provider.getPlanesList();
      // Verify the results
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
      // Call the addPlan function
      final Plan addedPlan = await provider.addPlan(
        'Plan 1',
        'This is a sample plan',
        {'min': '180', 'max': '200'},
        {'min': '180', 'max': '200'},
      );

      // Verify the results
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
      // Add mock data to the fake Firestore
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

      // Ensure the plan and its associated week exist before deletion
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
      // Call the deletePlan function
      await provider.deletePlan(planDoc.id);

      // Verify the plan and its associated week have been deleted
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
      // Add a mock plan document to the fake Firestore
      final planDoc = await fakeFirestore.collection('plan').add({
        'name': 'Original Plan',
        'description': 'Original description',
        'weight': {'min': '70', 'max': '75'},
        'height': {'min': '180', 'max': '200'},
      });

      // New values to update the plan document with
      const newName = 'Updated Plan';
      const newDescription = 'Updated description';
      final newWeight = {'min': '75', 'max': '80'};
      final newHeight = {'min': '185', 'max': '190'};

      // Call the updatePlan function
      await provider.updatePlan(
          planDoc.id, newName, newDescription, newWeight, newHeight);

      // Retrieve the updated plan document
      final updatedPlanDoc =
          await fakeFirestore.collection('plan').doc(planDoc.id).get();

      // Verify the updated plan document contains the new values
      expect(updatedPlanDoc.data()!['name'], equals(newName));
      expect(updatedPlanDoc.data()!['description'], equals(newDescription));
      expect(updatedPlanDoc.data()!['weight'], equals(newWeight));
      expect(updatedPlanDoc.data()!['height'], equals(newHeight));
    });
  });

  group('Funcionalidad Ejercicios', () {
    test('Add week', () async {
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );

      // Add the mock plan to Firestore
      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });

      // Add a week to the plan
      await provider.addWeek(1, plan);

      // Verify the week has been added in Firestore
      final weekSnapshot = await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .get();
      expect(weekSnapshot.docs.length, equals(1));
      expect(weekSnapshot.docs.first.data()['number'], equals(1));

      // Verify the week has been added to the plan object
      expect(plan.weeks.length, equals(1));
      expect(plan.weeks.first.numero, equals(1));
    });

    test('addEjercicioASemana adds an exercise to a specific week in the plan',
        () async {
      // Create a mock plan object
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );

      // Add the mock plan to Firestore
      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });

      // Add a mock week to the plan
      const weekNumber = 'week1';
      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });

      // Define exercise attributes
      const name = 'Push Up';
      const descripcion = 'An upper body exercise';
      const serie = 3;
      const repeticion = 15;
      const carga = null;
      const ejecucion = '60'; // Changed from int to String
      const pausa = '30'; // Changed from int to String
      const dia = 'Monday';

      // Call the addEjercicioASemana function
      await provider.addEjercicioASemana(plan, weekNumber, name, descripcion,
          serie, repeticion, carga, ejecucion, pausa, dia);

      // Verify the exercise has been added in Firestore
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
      // Create a mock plan object
      final plan = Plan(
        planId: 'plan1',
        name: 'Sample Plan',
        description: 'A sample plan',
        weight: {'min': '70', 'max': '75'},
        height: {'min': '180', 'max': '200'},
        weeks: [],
      );

      // Add the mock plan to Firestore
      await fakeFirestore.collection('plan').doc(plan.planId).set({
        'name': plan.name,
        'description': plan.description,
        'weight': plan.weight,
        'height': plan.height,
      });

      // Add a mock week to the plan
      const weekNumber = 'week1';
      await fakeFirestore
          .collection('plan')
          .doc(plan.planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });

      // Add mock exercises to the week for different days
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

      // Call the getEjerciciosDelDiaList function to retrieve exercises for 'Monday'
      final exercisesMonday =
          await provider.getEjerciciosDelDiaList(plan, weekNumber, 'Monday');

      // Verify that only the exercise for 'Monday' is retrieved
      expect(exercisesMonday.length, equals(1));
      expect(exercisesMonday.first.nombre, equals('Push Up'));
    });
    test(
        'addUsuarioARutina adds users to the subscripto subcollection and assigns the plan to each user',
        () async {
      // Define a plan ID
      const planId = 'plan1';

      // Define mock weight and height maps
      final weight = {'min': '180', 'max': '200'};
      final height = {'min': '150', 'max': '180'};

      // Create a list of mock UsuarioBasico objects
      final users = [
        UsuarioBasico(
            docId: 'user1',
            email: 'user1@example.com',
            nombreCompleto: 'User One',
            telefono: '1234567890',
            fcmToken: '123',
            rutina: 'fake_rutina'),
        UsuarioBasico(
            docId: 'user2',
            email: 'user2@example.com',
            nombreCompleto: 'User Two',
            telefono: '0987654321',
            fcmToken: '123',
            rutina: 'fake_rutina'),
      ];

      // Add the mock plan to Firestore
      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': weight,
        'height': height,
      });

      // Add mock user documents to the users collection
      for (final user in users) {
        await fakeFirestore.collection('usuario').doc(user.docId).set({
          'email': user.email,
          'nombreCompleto': user.nombreCompleto,
          'telefono': user.telefono,
          'peso': user.peso,
          'altura': user.altura,
        });
      }

      // Call the addUsuarioARutina function
      await provider.addUsuarioARutina(planId, users);

      // Verify that users are added to the subscripto subcollection
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

      // Verify that the plan is assigned to each user
      for (final user in users) {
        final userSnapshot =
            await fakeFirestore.collection('usuario').doc(user.docId).get();
        expect(userSnapshot.data()?['rutina'], equals(planId));
      }
    });
    test(
        'updateEjercicio updates an ejercicio document within a specific week in a plan',
        () async {
      // Define a plan ID
      const planId = 'plan1';

      // Define a week number
      const weekNumber = 'week1';

      // Define an ejercicio ID
      const ejercicioId = 'ejercicio1';

      // Add a mock plan to Firestore
      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });

      // Add a mock week to the plan
      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekNumber)
          .set({
        'number': 1,
      });

      // Add a mock ejercicio to the week
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

      // Define new values for the ejercicio
      const newName = 'New Name';
      const newDescripcion = 'New Description';
      const newSerie = 4;
      const newRepeticion = 12;
      const newCarga = 25;
      const newEjecucion = '35 min';
      const newPausa = '2 min';

      // Call the updateEjercicio function
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

      // Verify that the ejercicio document is updated
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
      // Define a plan ID and week ID
      const planId = 'plan1';
      const weekId = 'week1';

      // Add a mock plan to Firestore
      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });

      // Add a mock week to the plan
      await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .doc(weekId)
          .set({
        'number': 1,
      });

      // Add mock exercises to the week
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

      // Call the deleteExercisesfromWeek function
      await provider.deleteExercisesfromWeek(planId, weekId);

      // Verify that the ejercicio subcollection is empty
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
      // Define a plan ID
      const planId = 'plan1';

      // Add a mock plan to Firestore
      await fakeFirestore.collection('plan').doc(planId).set({
        'name': 'Sample Plan',
        'description': 'A sample plan',
        'weight': {'min': '180', 'max': '200'},
        'height': {'min': '150', 'max': '180'},
      });

      // Add mock weeks to the plan
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

      // Call the deleteWeeksFromPlan function
      await provider.deleteWeeksFromPlan(planId);

      // Verify that the week subcollection is empty
      final weekSnapshot = await fakeFirestore
          .collection('plan')
          .doc(planId)
          .collection('week')
          .get();
      expect(weekSnapshot.docs.isEmpty, isTrue);
    });
    test('deleteEjercicio deletes a specific exercise in a specific week', () async {
    // Define a plan ID and week ID
    const planId = 'plan1';
    const weekId = 'week1';
    const ejercicioId = 'ejercicio1';

    // Add a mock plan to Firestore
    await fakeFirestore.collection('plan').doc(planId).set({
      'name': 'Sample Plan',
      'description': 'A sample plan',
      'weight': {'min': '180', 'max': '200'},
      'height': {'min': '150', 'max': '180'},
    });

    // Add a mock week to the plan
    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId).set({
      'number': 1,
    });

    // Add a mock exercise to the week
    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId).collection('ejercicio').doc(ejercicioId).set({
      'nombre': 'Ejercicio 1',
      'descripcion': 'Descripcion 1',
      'serie': 3,
      'repeticion': 10,
      'carga': 20,
      'ejecucion': '30 min',
      'pausa': '1 min',
      'dia': 'Lunes',
    });

    // Create a mock Plan object
    final plan = Plan(
      planId: planId,
      name: 'Sample Plan',
      description: 'A sample plan',
      weight: {'min': '180', 'max': '200'},
      height: {'min': '150', 'max': '180'},
      weeks: [],
    );

    // Call the deleteEjercicio function
    await provider.deleteEjercicio(plan, weekId, ejercicioId);

    // Verify that the ejercicio document is deleted
    final ejercicioSnapshot = await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId).collection('ejercicio').doc(ejercicioId).get();
    expect(ejercicioSnapshot.exists, isFalse);
  });

    test('deleteWeek deletes the last week and its exercises from a specific plan', () async {

    // Define a plan ID and week ID
    const planId = 'plan1';
    const weekId1 = 'week1';
    const weekId2 = 'week2';
    const ejercicioId1 = 'ejercicio1';
    const ejercicioId2 = 'ejercicio2';

    // Add a mock plan to Firestore
    await fakeFirestore.collection('plan').doc(planId).set({
      'name': 'Sample Plan',
      'description': 'A sample plan',
      'weight': {'min': '180', 'max': '200'},
      'height': {'min': '150', 'max': '180'},
    });

    // Add mock weeks to the plan
    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId1).set({
      'number': 1,
    });
    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).set({
      'number': 2,
    });

    // Add mock exercises to the last week
    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).collection('ejercicio').doc(ejercicioId1).set({
      'nombre': 'Ejercicio 1',
      'descripcion': 'Descripcion 1',
      'serie': 3,
      'repeticion': 10,
      'carga': 20,
      'ejecucion': '30 min',
      'pausa': '1 min',
      'dia': 'Lunes',
    });

    await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).collection('ejercicio').doc(ejercicioId2).set({
      'nombre': 'Ejercicio 2',
      'descripcion': 'Descripcion 2',
      'serie': 4,
      'repeticion': 12,
      'carga': 25,
      'ejecucion': '45 min',
      'pausa': '2 min',
      'dia': 'Martes',
    });

    // Create a mock Plan object
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

    // Call the deleteWeek function
    await provider.deleteWeek(plan);

    // Verify that the last week and its exercises are deleted
    final weekSnapshot = await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).get();
    expect(weekSnapshot.exists, isFalse);

    final ejercicioSnapshot1 = await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).collection('ejercicio').doc(ejercicioId1).get();
    expect(ejercicioSnapshot1.exists, isFalse);

    final ejercicioSnapshot2 = await fakeFirestore.collection('plan').doc(planId).collection('week').doc(weekId2).collection('ejercicio').doc(ejercicioId2).get();
    expect(ejercicioSnapshot2.exists, isFalse);
  });

  });
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockFlutterLocalNotificationsPlugin extends Mock
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        FlutterLocalNotificationsPlugin {}
