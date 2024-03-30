import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://nrkpoxttysbxitcnligl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya3BveHR0eXNieGl0Y25saWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0Njk1MzUsImV4cCI6MjAyNzA0NTUzNX0.UQTzGaDyyCUepnqj2MzxH3XUyTXpsINyuVxDrB_fiYU',
  );

  runApp(MaterialApp(home: agregarmusica(),));

}

class agregarmusica extends StatefulWidget {
  agregarmusica({super.key});

  @override
  State<agregarmusica> createState() => _agregarmusicaState();
}

class _agregarmusicaState extends State<agregarmusica> {
  final control1 = TextEditingController();
  final control2 = TextEditingController();
  final base = Supabase.instance.client.from('Canciones').stream(primaryKey: ['id']);

@override
  void initState() {
    super.initState();
    
    Supabase.instance.client
        .channel('Canciones')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'Canciones',
            callback: (payload) {
              debugPrint('');
             
            })
        .subscribe();
    Supabase.instance.client
        .channel('Like_dislike')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'Like_dislike',
            callback: (payload) {
              debugPrint('');
             
            })
        .subscribe();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: Color.fromARGB(255, 48, 252, 126),title: const Text('Canciones'),), 
            body: Container(
              decoration: new BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 26, 253, 121),Color.fromARGB(255, 33, 253, 117),Color.fromARGB(255, 14, 245, 206)],
            stops: [0.5,0.5,0.8],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter
          )
        ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Nombre de la cancion'),
                  const SizedBox(height: 12,),
                  TextField(
                    controller: control1 ,
                    decoration: const InputDecoration(
                    border: OutlineInputBorder()
                  )),
                  const Text('Artista'),
                  const SizedBox(height: 12,),
                  TextField(
                    controller: control2,
                    decoration:const InputDecoration(
                    border: OutlineInputBorder()
                  )),
                  StreamBuilder(stream: base, builder: (context, snapshot){

                    return
                    Column(children: [
                      Text(''),
                      ElevatedButton(
                    onPressed:() async {
                      await Supabase.instance.client.from('Canciones').upsert([{'Nombre':control1.text, 'Artista':control2.text}]).select('Nombre,Artista');
                      await Supabase.instance.client.from('Like_dislike').upsert([{'Likes':0, 'Dislike':0}]).select('Likes,Dislike');
                      control1.clear();
                      control2.clear();
                    } , 
                    child: const Text("Agregar cancion", style: TextStyle(color: Color.fromARGB(255, 0, 173, 204)),))
                    ],)
                     ;
                  })
                  
                ],
              ),
            ),
    );
  }
}