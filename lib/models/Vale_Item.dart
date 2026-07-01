import 'Material.dart';
import 'Proyecto.dart';

class ValeItem {

  final Material material;
  Proyecto? proyecto;
  double cantidad;
  String unidad;

  ValeItem({
    required this.material,
    this.proyecto,
    this.cantidad = 1,
    this.unidad = 'pza',
  });
}

