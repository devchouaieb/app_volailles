class BirdCategory {
  final String name;
  final List<BirdSpecies> species;

  BirdCategory({required this.name, required this.species});
}

class BirdSpecies {
  final String scientificName;
  final String commonName;
  final String category;

  BirdSpecies({
    required this.scientificName,
    required this.commonName,
    required this.category,
  });
}

final List<BirdCategory> birdCategories = [
  BirdCategory(
    name: 'Canaris',
    species: [
      BirdSpecies(
        scientificName: 'Serinus canaria',
        commonName: 'Canari Harz classique',
        category: 'Canaris',
      ),
      BirdSpecies(
        scientificName: 'Serinus canaria',
        commonName: 'Canari Lipochrome mosaïque rouge',
        category: 'Canaris',
      ),
      BirdSpecies(
        scientificName: 'Serinus canaria',
        commonName: 'Canari Mélanine opale jaune',
        category: 'Canaris',
      ),
      BirdSpecies(
        scientificName: 'Serinus canaria',
        commonName: 'Canari panaché à fond blanc',
        category: 'Canaris',
      ),
    ],
  ),
  BirdCategory(
    name: 'Astrilds',
    species: [
      BirdSpecies(
        scientificName: 'Pytilia melba',
        commonName: 'Beaumarquet melba',
        category: 'Astrilds',
      ),
      BirdSpecies(
        scientificName: 'Lagonosticta senegala',
        commonName: 'Amarante du Sénégal',
        category: 'Astrilds',
      ),
      BirdSpecies(
        scientificName: 'Estrilda astrild',
        commonName: 'Astrild ondulé',
        category: 'Astrilds',
      ),
      BirdSpecies(
        scientificName: 'Amandava amandava',
        commonName: 'Bengali rouge',
        category: 'Astrilds',
      ),
      BirdSpecies(
        scientificName: 'Uraeginthus bengalus',
        commonName: 'Cordonbleu à joues rouges',
        category: 'Astrilds',
      ),
    ],
  ),
  BirdCategory(
    name: 'Perroquets',
    species: [
      BirdSpecies(
        scientificName: 'Forpus coelestis',
        commonName: 'Toui céleste',
        category: 'Perroquets',
      ),
      BirdSpecies(
        scientificName: 'Forpus xanthops',
        commonName: 'Toui à tête jaune',
        category: 'Perroquets',
      ),
      BirdSpecies(
        scientificName: 'Pyrrhura cruentata',
        commonName: 'Conure tiriba',
        category: 'Perroquets',
      ),
      BirdSpecies(
        scientificName: 'Psittacula krameri',
        commonName: 'Perruche à collier',
        category: 'Perroquets',
      ),
    ],
  ),
  BirdCategory(
    name: 'Colombes',
    species: [
      BirdSpecies(
        scientificName: 'Goura cristata',
        commonName: 'Goura couronné',
        category: 'Colombes',
      ),
      BirdSpecies(
        scientificName: 'Ptilinopus spp.',
        commonName: 'Ptilopes',
        category: 'Colombes',
      ),
      BirdSpecies(
        scientificName: 'Ducula spp.',
        commonName: 'Carpophages',
        category: 'Colombes',
      ),
      BirdSpecies(
        scientificName: 'Geopelia cuneata',
        commonName: 'Colombe diamant',
        category: 'Colombes',
      ),
    ],
  ),
  BirdCategory(
    name: 'Passereaux',
    species: [
      BirdSpecies(
        scientificName: 'Corvus corone',
        commonName: 'Corneille noire',
        category: 'Passereaux',
      ),
      BirdSpecies(
        scientificName: 'Pica pica',
        commonName: 'Pie bavarde',
        category: 'Passereaux',
      ),
      BirdSpecies(
        scientificName: 'Turdus merula',
        commonName: 'Merle noir',
        category: 'Passereaux',
      ),
    ],
  ),
];

// Helper function to get all species
List<BirdSpecies> getAllBirdSpecies() {
  return birdCategories.expand((category) => category.species).toList();
}

// Helper function to get species by category
List<BirdSpecies> getBirdSpeciesByCategory(String category) {
  return birdCategories.firstWhere((cat) => cat.name == category).species;
}

// Helper function to get all categories
List<String> getAllCategories() {
  return birdCategories.map((category) => category.name).toList();
}
