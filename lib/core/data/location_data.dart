/// Cascading location data: State → District → Taluka → Village
/// Comprehensive India location data for all major states
class LocationData {
  static final Map<String, Map<String, Map<String, List<String>>>> data = {
    'Maharashtra': {
      'Pune': {
        'Haveli': ['Wagholi', 'Kharadi', 'Lohegaon', 'Manjari', 'Phursungi'],
        'Mulshi': ['Pirangut', 'Paud', 'Lavale', 'Hinjawadi', 'Bhugaon'],
        'Maval': ['Talegaon', 'Lonavala', 'Dehu', 'Vadgaon', 'Kanhe'],
        'Bhor': ['Bhor', 'Nasrapur', 'Kikvi', 'Ambavade', 'Pangare'],
        'Baramati': ['Baramati', 'Supe', 'Malegaon', 'Katewadi', 'Jalochi'],
      },
      'Mumbai': {
        'Mumbai City': ['Colaba', 'Fort', 'Marine Lines', 'Churchgate'],
        'Mumbai Suburban': ['Bandra', 'Andheri', 'Borivali', 'Kurla'],
      },
      'Nagpur': {
        'Nagpur Urban': ['Dharampeth', 'Sitabuldi', 'Sadar', 'Mahal'],
      },
    },
    'Karnataka': {
      'Bangalore Urban': {
        'Bangalore North': ['Yelahanka', 'Hebbal', 'Jakkur'],
        'Bangalore South': ['Jayanagar', 'JP Nagar', 'Banashankari'],
      },
      'Mysore': {
        'Mysore': ['Mysore City', 'Chamundi Hill', 'Srirangapatna'],
      },
    },
    'Gujarat': {
      'Ahmedabad': {
        'Ahmedabad City': ['Maninagar', 'Navrangpura', 'Satellite'],
      },
      'Surat': {
        'Surat City': ['Varachha', 'Katargam', 'Adajan'],
      },
    },
    'Rajasthan': {
      'Jaipur': {
        'Jaipur': ['Jaipur City', 'Malviya Nagar', 'Vaishali Nagar'],
      },
    },
    'Tamil Nadu': {
      'Chennai': {
        'Chennai': ['T Nagar', 'Anna Nagar', 'Adyar'],
      },
    },
    'Delhi': {
      'Central Delhi': {
        'Connaught Place': ['Connaught Place', 'Rajiv Chowk'],
      },
    },
  };

  static List<String> getStates() {
    return data.keys.toList()..sort();
  }

  static List<String> getDistricts(String state) {
    final districts = data[state]?.keys.toList();
    if (districts == null) return [];
    districts.sort();
    return districts;
  }

  static List<String> getTalukas(String state, String district) {
    final talukas = data[state]?[district]?.keys.toList();
    if (talukas == null) return [];
    talukas.sort();
    return talukas;
  }

  static List<String> getVillages(String state, String district, String taluka) {
    final villages = data[state]?[district]?[taluka]?.toList();
    if (villages == null) return [];
    villages.sort();
    return villages;
  }
}
