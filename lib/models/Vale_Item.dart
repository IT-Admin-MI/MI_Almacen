import 'Material.dart';
import 'Proyecto.dart';

class ValeItem {

  final Material material;
  Proyecto? proyecto;
  double cantidad;
  String unidad;
  String comentarioVale;

  ValeItem({
    required this.material,
    this.proyecto,
    this.cantidad = 1,
    this.unidad = 'pza',
    String? comentarioVale,
  }) : this.comentarioVale = comentarioVale ?? "";
}