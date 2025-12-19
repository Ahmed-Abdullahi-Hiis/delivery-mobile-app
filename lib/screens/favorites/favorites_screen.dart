//  class FavoritesScreen extends StatelessWidget {
//   static const route = "/favorites";

//   @override
//   Widget build(BuildContext context) {
//     final favorites = context.watch<FavoriteProvider>().favorites;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Favorites")),
//       body: favorites.isEmpty
//           ? const Center(child: Text("No favorites yet ❤️"))
//           : ListView.builder(
//               itemCount: favorites.length,
//               itemBuilder: (_, i) => ListTile(
//                 leading: Image.asset(favorites[i].image, width: 50),
//                 title: Text(favorites[i].name),
//               ),
//             ),
//     );
//   }
// }
