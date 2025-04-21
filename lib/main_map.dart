import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';

/// Widget que muestra un mapa iterativo utilizando FlutterMap
/// Este Widget utiliza StateFulWidget para manejar la lógica de estado
/// como la ubicación actual del usuario y la visualización de los marcadores
class MainMap extends StatefulWidget{
    @override
    _MainMapState createState() => _MainMapState();
}

/// Estado asociado al Widget MainMap
/// Se encarga de controlar el mapa, manejar los permisos de ubicación
/// agregar los marcadores y mover la cámara del mapa a la ubicación del usuario
class _MainMapState extends State<MainMap> {
  
  /// variable usada para controlar el mapa
  final mapController = MapController();     

  /// variable utilizada como lista de los marcadores de ubicación
  late List<Marker> markers;

  /// función auxiliar para construir un marcador
  /// recibe la ubicación del marcador y los demás atributos se reutilizan
  Marker buildUserMarker(LatLng location) {
  return Marker(
    point: location,
    width: 40,
    height: 40,
    child: Icon(
      Icons.location_pin,
      color: Colors.blue,
      size: 40,
    ),
  );
}
  /// se inicializa la variable "markets" con un marcador ubicado en San José
    @override
    void initState(){
      super.initState();

      /// inicializamos un marcado en la ubicación de San José
      markers = [        
        buildUserMarker(LatLng(9.9280694, -84.0907246)),
      ];
      
      /// se utiliza el "WidgetBinding.instance.addPostFrameCallBack"
      /// para instanciar ejecutar la función "_addCurrentLocationMarkert"
      /// luego de montar el widget del mapa ha sido montado en pantalla
      /// Esto asegura que el mapa este redenderizado antes de intentar montar
      /// un marcador o mover la cámara, evitando errores como:
      /// "You need to have the FlutterMap widget rendered at least once
      /// before using the MapController".
      /// (Este fue un error que surgió al intentar mover el mapa antes de que se renderizara).      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addCurrentLocationMarkert();
      });
    }

    /// función que se encarga de:
    /// verificar los permisos de ubicación
    /// obtiene la ubicación del usuario
    /// mueve el marcador [0] a la nueva posición del usuario
    Future<void> _addCurrentLocationMarkert() async {
      try{
                
        LocationPermission permission;
        final locationService = LocationService();

        /// Verifica si el servicio de ubicación está habilitado
        bool serviceEnabled = await locationService.isServiceEnabled();
        if (!serviceEnabled) {
          print("El servicio de ubicación está deshabilitado");
          return;
        }        

        /// Verifica si tienes permisos para acceder a la ubicación
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print("Permiso denegado");
            return;
          }
        }

        /// verifica la denegación permanente del permiso de ubicación
        if (permission == LocationPermission.deniedForever) {
          print("Permiso permanentemente denegado");
          return;
        }

        /// Obtiene la ubicación actual
        Position position = await locationService.getCurrentLocation();        

        /// variable utilizada para tomar la ubicación del usuario
        /// por latitud y longitud
        final userLocation = LatLng(position.latitude, position.longitude);

        /// se cambia actualiza el estado de los marcadores
        /// ubicando el marcador [0] en la ubicación del usuario
        setState(() {
          markers = [ buildUserMarker(userLocation) ];
        });

        /// se vuelve a usar "WidgetsBinding.instance.addPostFrameCallback"
        /// para mover la cámara del mapa a la ubicacion del usuario
        /// con un zoom 18.0, pero, luego de montar el mapa, obtener los permisos de ubicación,
        /// asignarle los nuevos valores al marcador y colocar de nuevo el marcador en el mapa
        WidgetsBinding.instance.addPostFrameCallback((_){
          mapController.move(userLocation, 18.0);
        });        
        
      } catch (e) {
        print('Error obteniendo ubicación: $e');
      }
    }

    /// se contruye le mapa con sus atributos
    /// el boton de ubicación, que al ser seleccionado actualiza la ubicacion del usuario
    /// se asignan los controladores para el flutterMap
    @override 
    Widget build( BuildContext context) {      
        return Scaffold(
            appBar: AppBar(
              title: Text("Map with Leaflet"), 
              actions: [IconButton(
                onPressed: () => _addCurrentLocationMarkert(), 
                icon: Icon(Icons.my_location))
              ],),
            body: FlutterMap(
              mapController: mapController,
                options: MapOptions (
                    initialCenter: LatLng(9.93333, -84.08333),
                    initialZoom: 8.0,
                    maxZoom: 15.0,
                ),                        
                children: [
                    TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",                        
                    ),
                    MarkerClusterLayerWidget (
                        options: MarkerClusterLayerOptions(
                            maxClusterRadius: 45,
                            size: const Size(40, 40),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(50),
                            maxZoom: 15,        
                            markers: markers,
                            builder: (context, markers) {
                                return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.blue),
                                    child: Center(
                                        child: Text(
                                        markers.length.toString(),
                                        style: const TextStyle(color: Colors.white),
                                        ),
                                    ),
                                );
                            },
                        ),
                    ),                    
                ],
            ),
        );
    }
}    