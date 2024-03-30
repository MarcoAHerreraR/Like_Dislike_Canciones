//contra:tWGxak6J6vSyvt2z
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:canciones/Paginas/p1.dart' as p1;
import 'variables.dart' as globales;


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://nrkpoxttysbxitcnligl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya3BveHR0eXNieGl0Y25saWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0Njk1MzUsImV4cCI6MjAyNzA0NTUzNX0.UQTzGaDyyCUepnqj2MzxH3XUyTXpsINyuVxDrB_fiYU',
  );
  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:myhomepage()
    );
  }
}

// ignore: camel_case_types
class myhomepage extends StatefulWidget {
  const myhomepage({super.key});


  @override
  State<myhomepage> createState() => _myhomepageState();
}

class _myhomepageState extends State<myhomepage> {
  final base = Supabase.instance.client.from('Canciones').stream(primaryKey: ['id']);
  final base2 = Supabase.instance.client.from('Like_dislike').stream(primaryKey: ['id']);
  final datos = Supabase.instance.client.from('Canciones').select('''Nombre,Artista''');
  final likedislike = Supabase.instance.client.from('Like_dislike').select('''id,Likes,Dislike''');

@override
  void initState() {
    super.initState();
    
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
      appBar:
       AppBar(backgroundColor: Color.fromARGB(255, 48, 252, 126),centerTitle: true, title: const Text('Canciones') , actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> p1.agregarmusica()));
            },),] ), 
      body: Container(
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 26, 253, 121),Color.fromARGB(255, 33, 253, 117),Color.fromARGB(255, 14, 245, 206)],
            stops: [0.5,0.5,0.8],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter
          )
        ),
        child: Center(
          child:FutureBuilder(future: datos, builder: (context,snapshot){
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
         return const CircularProgressIndicator();
        }
        debugPrint('Cambios recibidos por stream ${snapshot.data}');
        final data = snapshot.data as List;
        return ListView.builder(itemCount: data.length, itemBuilder:(context, index) {
          //var canciones = data[index];
          return Row(
            children: [
              Text('Nombre: ' + data[index]['Nombre']),
              Text(' Artista: ' + data[index]['Artista']),
        FutureBuilder(future: likedislike, builder: (context,snapshot){
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
         return const CircularProgressIndicator();
        }
        final like = snapshot.data![index]['Likes'].toString();
        final dislike = snapshot.data![index]['Dislike'].toString();
        return Row(
          children: [
            IconButton(onPressed: () async {
            globales.likes = int.parse(like);
            globales.likes = globales.likes + 1;
            await Supabase.instance.client.from('Like_dislike').update({'Likes':globales.likes}).match({'Likes':like}).order('id',ascending: true);
        }, icon: const Icon(Icons.thumb_up)),
        Text(like),
        IconButton(onPressed: () async {
          globales.dislike = int.parse(dislike);
          globales.dislike = globales.dislike + 1;
          await Supabase.instance.client.from('Like_dislike').update({'Dislike':globales.dislike}).match({'Dislike':dislike}).order('id',ascending: true);
          //debugPrint(snapshot.data![index]['id'].toString());
        }, icon: const Icon(Icons.thumb_down)),
        Text(dislike)],
        );
        })
            ],
          );
        },);
        } ,
        ),
            ),
      ));
  }
}
