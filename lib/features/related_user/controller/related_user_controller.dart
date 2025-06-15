import '../../../core/models/related_user.dart';
import '../../../core/services/related_user_service.dart';
import '../../../core/state/related_user_state.dart';

class RelatedUserController {
  static final RelatedUserController _instance =
      RelatedUserController._internal();

  factory RelatedUserController() => _instance;

  RelatedUserController._internal();

  final RelatedUserState _relatedUserState = RelatedUserState();
  final RelatedUserService _relatedUserService = RelatedUserService();

  Future<void> create({
    required String name,
    String? email,
    String? phone,
  }) async {
    final relatedUser = await _relatedUserService.create(
      name: name,
      email: email,
      phone: phone,
    );
    _relatedUserState.addRelatedUser(relatedUser);
  }

  Future<void> edit({
    required RelatedUser old,
    required String name,
    String? email,
    String? phone,
  }) async {
    await _relatedUserService.edit(
      id: old.id!,
      name: name,
      email: email,
      phone: phone,
    );

    final newUser = old.copyWith();
    newUser.name = name;
    newUser.email = email;
    newUser.phone = phone;

    _relatedUserState.updateRelatedUser(newUser);
  }
}
