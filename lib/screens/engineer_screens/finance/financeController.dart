import 'package:get/get.dart';

class FinanceController extends GetxController {
  RxInt reload = 0.obs;
  RxList fileInformation = [].obs;
  RxBool isload = false.obs;
}