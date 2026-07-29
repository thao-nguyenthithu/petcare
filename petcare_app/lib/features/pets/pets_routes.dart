import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/screens/add_pet_screen.dart';
import 'package:petcare_app/features/pets/screens/my_pets_screen.dart';
import 'package:petcare_app/features/pets/screens/pet_detail_screen.dart';
import 'package:petcare_app/features/pets/screens/pet_health_screen.dart';
import 'package:petcare_app/features/pets/screens/prevention_detail_screen.dart';
import 'package:petcare_app/features/pets/screens/prevention_dose_form_screen.dart';

// Route cụm thú cưng
final petsRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.myPets,
    builder: (context, state) => const MyPetsScreen(),
  ),
  GoRoute(
    path: AppRoutes.petDetail,
    builder: (context, state) =>
        PetDetailScreen(args: state.extra as PetDetailArgs),
  ),
  GoRoute(
    path: AppRoutes.addPet,
    builder: (context, state) => AddPetScreen(petSua: state.extra as Pet?),
  ),
  GoRoute(
    path: AppRoutes.addPetHealth,
    builder: (context, state) {
      final args = state.extra as PetHealthArgs;
      return PetHealthScreen(
        tenBe: args.tenBe,
        loaiBe: args.loaiBe,
        petSua: args.petSua,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.preventionDetail,
    // Chi tiết một hạng mục
    builder: (context, state) =>
        PreventionDetailScreen(args: state.extra as PreventionDetailArgs),
  ),
  GoRoute(
    path: AppRoutes.preventionDose,
    builder: (context, state) =>
        PreventionDoseFormScreen(args: state.extra as PreventionDoseFormArgs),
  ),
];
