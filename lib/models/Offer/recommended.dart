import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';

class Recommended {
  final int id;
  final Service service;
  final Branch branch;

  Recommended({required this.id, required this.service, required this.branch});

  factory Recommended.fromJson(Map<String, dynamic> json) {
    return Recommended(
      id: json['id'],
      service: Service.fromJson(json['service']),
      branch: Branch.fromJson(json['branch']),
    );
  }
}
