import 'package:vm_service/vm_service.dart';

import 'equatable.dart';

class BlocNode extends Equatable {
  const BlocNode({
    required this.blocName,
    required this.fileUri,
    required this.id,
  });

  factory BlocNode.fromMapAssociation(MapAssociation association) {
    final InstanceRef value = association.value;
    return BlocNode(
      blocName: value.classRef!.name!,
      fileUri: value.classRef!.location!.script!.uri!,
      id: value.classRef!.id!,
    );
  }

  final String blocName;
  final String id;
  final String fileUri;

  @override
  List<Object?> get props => [blocName, id, fileUri];
}
