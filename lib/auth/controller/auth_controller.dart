// import 'package: flutter/material.dart';
//
// import '../../common/utils/utils.dart';
//
//
//
// class AuthController{
//   final AuthRepository authRepository;
//   AuthController({required this.authRepository});
//
//   void saveUserDataToFirebase(BuildContext context, String name, File? profilePic) async {
//     try{
//       await authRepository.saveUserDataToFirebase(user);
//     } catch(e) {
//       if(context.mounted){
//         showSnackBar(context: context, content: e.toString());
//       }
//     }
//   }
// }