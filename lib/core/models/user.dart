import 'package:utsavlife/core/models/service.dart';
import '../provider/RegisterProvider.dart';
class Country{
  String id,name;
  Country({
    required this.id,
    required this.name
  });
  factory Country.fromJson(Map json){
    return Country(id: json["id"].toString(), name: json["name"]);
  }
  @override
  String toString(){
    return this.name;
  }
}

List<Map> DefaultCountries = [
  {
    "id": 1,
    "sortname": "AF",
    "name": "Afghanistan"
  },
  {
    "id": 2,
    "sortname": "AL",
    "name": "Albania"
  },
  {
    "id": 3,
    "sortname": "DZ",
    "name": "Algeria"
  },
  {
    "id": 4,
    "sortname": "AS",
    "name": "American Samoa"
  },
  {
    "id": 5,
    "sortname": "AD",
    "name": "Andorra"
  },
  {
    "id": 6,
    "sortname": "AO",
    "name": "Angola"
  },
  {
    "id": 7,
    "sortname": "AI",
    "name": "Anguilla"
  },
  {
    "id": 8,
    "sortname": "AQ",
    "name": "Antarctica"
  },
  {
    "id": 9,
    "sortname": "AG",
    "name": "Antigua And Barbuda"
  },
  {
    "id": 10,
    "sortname": "AR",
    "name": "Argentina"
  },
  {
    "id": 11,
    "sortname": "AM",
    "name": "Armenia"
  },
  {
    "id": 12,
    "sortname": "AW",
    "name": "Aruba"
  },
  {
    "id": 13,
    "sortname": "AU",
    "name": "Australia"
  },
  {
    "id": 14,
    "sortname": "AT",
    "name": "Austria"
  },
  {
    "id": 15,
    "sortname": "AZ",
    "name": "Azerbaijan"
  },
  {
    "id": 16,
    "sortname": "BS",
    "name": "Bahamas The"
  },
  {
    "id": 17,
    "sortname": "BH",
    "name": "Bahrain"
  },
  {
    "id": 18,
    "sortname": "BD",
    "name": "Bangladesh"
  },
  {
    "id": 19,
    "sortname": "BB",
    "name": "Barbados"
  },
  {
    "id": 20,
    "sortname": "BY",
    "name": "Belarus"
  },
  {
    "id": 21,
    "sortname": "BE",
    "name": "Belgium"
  },
  {
    "id": 22,
    "sortname": "BZ",
    "name": "Belize"
  },
  {
    "id": 23,
    "sortname": "BJ",
    "name": "Benin"
  },
  {
    "id": 24,
    "sortname": "BM",
    "name": "Bermuda"
  },
  {
    "id": 25,
    "sortname": "BT",
    "name": "Bhutan"
  },
  {
    "id": 26,
    "sortname": "BO",
    "name": "Bolivia"
  },
  {
    "id": 27,
    "sortname": "BA",
    "name": "Bosnia and Herzegovina"
  },
  {
    "id": 28,
    "sortname": "BW",
    "name": "Botswana"
  },
  {
    "id": 29,
    "sortname": "BV",
    "name": "Bouvet Island"
  },
  {
    "id": 30,
    "sortname": "BR",
    "name": "Brazil"
  },
  {
    "id": 31,
    "sortname": "IO",
    "name": "British Indian Ocean Territory"
  },
  {
    "id": 32,
    "sortname": "BN",
    "name": "Brunei"
  },
  {
    "id": 33,
    "sortname": "BG",
    "name": "Bulgaria"
  },
  {
    "id": 34,
    "sortname": "BF",
    "name": "Burkina Faso"
  },
  {
    "id": 35,
    "sortname": "BI",
    "name": "Burundi"
  },
  {
    "id": 36,
    "sortname": "KH",
    "name": "Cambodia"
  },
  {
    "id": 37,
    "sortname": "CM",
    "name": "Cameroon"
  },
  {
    "id": 38,
    "sortname": "CA",
    "name": "Canada"
  },
  {
    "id": 39,
    "sortname": "CV",
    "name": "Cape Verde"
  },
  {
    "id": 40,
    "sortname": "KY",
    "name": "Cayman Islands"
  },
  {
    "id": 41,
    "sortname": "CF",
    "name": "Central African Republic"
  },
  {
    "id": 42,
    "sortname": "TD",
    "name": "Chad"
  },
  {
    "id": 43,
    "sortname": "CL",
    "name": "Chile"
  },
  {
    "id": 44,
    "sortname": "CN",
    "name": "China"
  },
  {
    "id": 45,
    "sortname": "CX",
    "name": "Christmas Island"
  },
  {
    "id": 46,
    "sortname": "CC",
    "name": "Cocos (Keeling) Islands"
  },
  {
    "id": 47,
    "sortname": "CO",
    "name": "Colombia"
  },
  {
    "id": 48,
    "sortname": "KM",
    "name": "Comoros"
  },
  {
    "id": 49,
    "sortname": "CG",
    "name": "Congo"
  },
  {
    "id": 50,
    "sortname": "CD",
    "name": "Congo The Democratic Republic Of The"
  },
  {
    "id": 51,
    "sortname": "CK",
    "name": "Cook Islands"
  },
  {
    "id": 52,
    "sortname": "CR",
    "name": "Costa Rica"
  },
  {
    "id": 53,
    "sortname": "CI",
    "name": "Cote D'Ivoire (Ivory Coast)"
  },
  {
    "id": 54,
    "sortname": "HR",
    "name": "Croatia (Hrvatska)"
  },
  {
    "id": 55,
    "sortname": "CU",
    "name": "Cuba"
  },
  {
    "id": 56,
    "sortname": "CY",
    "name": "Cyprus"
  },
  {
    "id": 57,
    "sortname": "CZ",
    "name": "Czech Republic"
  },
  {
    "id": 58,
    "sortname": "DK",
    "name": "Denmark"
  },
  {
    "id": 59,
    "sortname": "DJ",
    "name": "Djibouti"
  },
  {
    "id": 60,
    "sortname": "DM",
    "name": "Dominica"
  },
  {
    "id": 61,
    "sortname": "DO",
    "name": "Dominican Republic"
  },
  {
    "id": 62,
    "sortname": "TP",
    "name": "East Timor"
  },
  {
    "id": 63,
    "sortname": "EC",
    "name": "Ecuador"
  },
  {
    "id": 64,
    "sortname": "EG",
    "name": "Egypt"
  },
  {
    "id": 65,
    "sortname": "SV",
    "name": "El Salvador"
  },
  {
    "id": 66,
    "sortname": "GQ",
    "name": "Equatorial Guinea"
  },
  {
    "id": 67,
    "sortname": "ER",
    "name": "Eritrea"
  },
  {
    "id": 68,
    "sortname": "EE",
    "name": "Estonia"
  },
  {
    "id": 69,
    "sortname": "ET",
    "name": "Ethiopia"
  },
  {
    "id": 70,
    "sortname": "XA",
    "name": "External Territories of Australia"
  },
  {
    "id": 71,
    "sortname": "FK",
    "name": "Falkland Islands"
  },
  {
    "id": 72,
    "sortname": "FO",
    "name": "Faroe Islands"
  },
  {
    "id": 73,
    "sortname": "FJ",
    "name": "Fiji Islands"
  },
  {
    "id": 74,
    "sortname": "FI",
    "name": "Finland"
  },
  {
    "id": 75,
    "sortname": "FR",
    "name": "France"
  },
  {
    "id": 76,
    "sortname": "GF",
    "name": "French Guiana"
  },
  {
    "id": 77,
    "sortname": "PF",
    "name": "French Polynesia"
  },
  {
    "id": 78,
    "sortname": "TF",
    "name": "French Southern Territories"
  },
  {
    "id": 79,
    "sortname": "GA",
    "name": "Gabon"
  },
  {
    "id": 80,
    "sortname": "GM",
    "name": "Gambia The"
  },
  {
    "id": 81,
    "sortname": "GE",
    "name": "Georgia"
  },
  {
    "id": 82,
    "sortname": "DE",
    "name": "Germany"
  },
  {
    "id": 83,
    "sortname": "GH",
    "name": "Ghana"
  },
  {
    "id": 84,
    "sortname": "GI",
    "name": "Gibraltar"
  },
  {
    "id": 85,
    "sortname": "GR",
    "name": "Greece"
  },
  {
    "id": 86,
    "sortname": "GL",
    "name": "Greenland"
  },
  {
    "id": 87,
    "sortname": "GD",
    "name": "Grenada"
  },
  {
    "id": 88,
    "sortname": "GP",
    "name": "Guadeloupe"
  },
  {
    "id": 89,
    "sortname": "GU",
    "name": "Guam"
  },
  {
    "id": 90,
    "sortname": "GT",
    "name": "Guatemala"
  },
  {
    "id": 91,
    "sortname": "XU",
    "name": "Guernsey and Alderney"
  },
  {
    "id": 92,
    "sortname": "GN",
    "name": "Guinea"
  },
  {
    "id": 93,
    "sortname": "GW",
    "name": "Guinea-Bissau"
  },
  {
    "id": 94,
    "sortname": "GY",
    "name": "Guyana"
  },
  {
    "id": 95,
    "sortname": "HT",
    "name": "Haiti"
  },
  {
    "id": 96,
    "sortname": "HM",
    "name": "Heard and McDonald Islands"
  },
  {
    "id": 97,
    "sortname": "HN",
    "name": "Honduras"
  },
  {
    "id": 98,
    "sortname": "HK",
    "name": "Hong Kong S.A.R."
  },
  {
    "id": 99,
    "sortname": "HU",
    "name": "Hungary"
  },
  {
    "id": 100,
    "sortname": "IS",
    "name": "Iceland"
  },
  {
    "id": 101,
    "sortname": "IN",
    "name": "India"
  },
  {
    "id": 102,
    "sortname": "ID",
    "name": "Indonesia"
  },
  {
    "id": 103,
    "sortname": "IR",
    "name": "Iran"
  },
  {
    "id": 104,
    "sortname": "IQ",
    "name": "Iraq"
  },
  {
    "id": 105,
    "sortname": "IE",
    "name": "Ireland"
  },
  {
    "id": 106,
    "sortname": "IL",
    "name": "Israel"
  },
  {
    "id": 107,
    "sortname": "IT",
    "name": "Italy"
  },
  {
    "id": 108,
    "sortname": "JM",
    "name": "Jamaica"
  },
  {
    "id": 109,
    "sortname": "JP",
    "name": "Japan"
  },
  {
    "id": 110,
    "sortname": "XJ",
    "name": "Jersey"
  },
  {
    "id": 111,
    "sortname": "JO",
    "name": "Jordan"
  },
  {
    "id": 112,
    "sortname": "KZ",
    "name": "Kazakhstan"
  },
  {
    "id": 113,
    "sortname": "KE",
    "name": "Kenya"
  },
  {
    "id": 114,
    "sortname": "KI",
    "name": "Kiribati"
  },
  {
    "id": 115,
    "sortname": "KP",
    "name": "Korea North"
  },
  {
    "id": 116,
    "sortname": "KR",
    "name": "Korea South"
  },
  {
    "id": 117,
    "sortname": "KW",
    "name": "Kuwait"
  },
  {
    "id": 118,
    "sortname": "KG",
    "name": "Kyrgyzstan"
  },
  {
    "id": 119,
    "sortname": "LA",
    "name": "Laos"
  },
  {
    "id": 120,
    "sortname": "LV",
    "name": "Latvia"
  },
  {
    "id": 121,
    "sortname": "LB",
    "name": "Lebanon"
  },
  {
    "id": 122,
    "sortname": "LS",
    "name": "Lesotho"
  },
  {
    "id": 123,
    "sortname": "LR",
    "name": "Liberia"
  },
  {
    "id": 124,
    "sortname": "LY",
    "name": "Libya"
  },
  {
    "id": 125,
    "sortname": "LI",
    "name": "Liechtenstein"
  },
  {
    "id": 126,
    "sortname": "LT",
    "name": "Lithuania"
  },
  {
    "id": 127,
    "sortname": "LU",
    "name": "Luxembourg"
  },
  {
    "id": 128,
    "sortname": "MO",
    "name": "Macau S.A.R."
  },
  {
    "id": 129,
    "sortname": "MK",
    "name": "Macedonia"
  },
  {
    "id": 130,
    "sortname": "MG",
    "name": "Madagascar"
  },
  {
    "id": 131,
    "sortname": "MW",
    "name": "Malawi"
  },
  {
    "id": 132,
    "sortname": "MY",
    "name": "Malaysia"
  },
  {
    "id": 133,
    "sortname": "MV",
    "name": "Maldives"
  },
  {
    "id": 134,
    "sortname": "ML",
    "name": "Mali"
  },
  {
    "id": 135,
    "sortname": "MT",
    "name": "Malta"
  },
  {
    "id": 136,
    "sortname": "XM",
    "name": "Man (Isle of)"
  },
  {
    "id": 137,
    "sortname": "MH",
    "name": "Marshall Islands"
  },
  {
    "id": 138,
    "sortname": "MQ",
    "name": "Martinique"
  },
  {
    "id": 139,
    "sortname": "MR",
    "name": "Mauritania"
  },
  {
    "id": 140,
    "sortname": "MU",
    "name": "Mauritius"
  },
  {
    "id": 141,
    "sortname": "YT",
    "name": "Mayotte"
  },
  {
    "id": 142,
    "sortname": "MX",
    "name": "Mexico"
  },
  {
    "id": 143,
    "sortname": "FM",
    "name": "Micronesia"
  },
  {
    "id": 144,
    "sortname": "MD",
    "name": "Moldova"
  },
  {
    "id": 145,
    "sortname": "MC",
    "name": "Monaco"
  },
  {
    "id": 146,
    "sortname": "MN",
    "name": "Mongolia"
  },
  {
    "id": 147,
    "sortname": "MS",
    "name": "Montserrat"
  },
  {
    "id": 148,
    "sortname": "MA",
    "name": "Morocco"
  },
  {
    "id": 149,
    "sortname": "MZ",
    "name": "Mozambique"
  },
  {
    "id": 150,
    "sortname": "MM",
    "name": "Myanmar"
  },
  {
    "id": 151,
    "sortname": "NA",
    "name": "Namibia"
  },
  {
    "id": 152,
    "sortname": "NR",
    "name": "Nauru"
  },
  {
    "id": 153,
    "sortname": "NP",
    "name": "Nepal"
  },
  {
    "id": 154,
    "sortname": "AN",
    "name": "Netherlands Antilles"
  },
  {
    "id": 155,
    "sortname": "NL",
    "name": "Netherlands The"
  },
  {
    "id": 156,
    "sortname": "NC",
    "name": "New Caledonia"
  },
  {
    "id": 157,
    "sortname": "NZ",
    "name": "New Zealand"
  },
  {
    "id": 158,
    "sortname": "NI",
    "name": "Nicaragua"
  },
  {
    "id": 159,
    "sortname": "NE",
    "name": "Niger"
  },
  {
    "id": 160,
    "sortname": "NG",
    "name": "Nigeria"
  },
  {
    "id": 161,
    "sortname": "NU",
    "name": "Niue"
  },
  {
    "id": 162,
    "sortname": "NF",
    "name": "Norfolk Island"
  },
  {
    "id": 163,
    "sortname": "MP",
    "name": "Northern Mariana Islands"
  },
  {
    "id": 164,
    "sortname": "NO",
    "name": "Norway"
  },
  {
    "id": 165,
    "sortname": "OM",
    "name": "Oman"
  },
  {
    "id": 166,
    "sortname": "PK",
    "name": "Pakistan"
  },
  {
    "id": 167,
    "sortname": "PW",
    "name": "Palau"
  },
  {
    "id": 168,
    "sortname": "PS",
    "name": "Palestinian Territory Occupied"
  },
  {
    "id": 169,
    "sortname": "PA",
    "name": "Panama"
  },
  {
    "id": 170,
    "sortname": "PG",
    "name": "Papua new Guinea"
  },
  {
    "id": 171,
    "sortname": "PY",
    "name": "Paraguay"
  },
  {
    "id": 172,
    "sortname": "PE",
    "name": "Peru"
  },
  {
    "id": 173,
    "sortname": "PH",
    "name": "Philippines"
  },
  {
    "id": 174,
    "sortname": "PN",
    "name": "Pitcairn Island"
  },
  {
    "id": 175,
    "sortname": "PL",
    "name": "Poland"
  },
  {
    "id": 176,
    "sortname": "PT",
    "name": "Portugal"
  },
  {
    "id": 177,
    "sortname": "PR",
    "name": "Puerto Rico"
  },
  {
    "id": 178,
    "sortname": "QA",
    "name": "Qatar"
  },
  {
    "id": 179,
    "sortname": "RE",
    "name": "Reunion"
  },
  {
    "id": 180,
    "sortname": "RO",
    "name": "Romania"
  },
  {
    "id": 181,
    "sortname": "RU",
    "name": "Russia"
  },
  {
    "id": 182,
    "sortname": "RW",
    "name": "Rwanda"
  },
  {
    "id": 183,
    "sortname": "SH",
    "name": "Saint Helena"
  },
  {
    "id": 184,
    "sortname": "KN",
    "name": "Saint Kitts And Nevis"
  },
  {
    "id": 185,
    "sortname": "LC",
    "name": "Saint Lucia"
  },
  {
    "id": 186,
    "sortname": "PM",
    "name": "Saint Pierre and Miquelon"
  },
  {
    "id": 187,
    "sortname": "VC",
    "name": "Saint Vincent And The Grenadines"
  },
  {
    "id": 188,
    "sortname": "WS",
    "name": "Samoa"
  },
  {
    "id": 189,
    "sortname": "SM",
    "name": "San Marino"
  },
  {
    "id": 190,
    "sortname": "ST",
    "name": "Sao Tome and Principe"
  },
  {
    "id": 191,
    "sortname": "SA",
    "name": "Saudi Arabia"
  },
  {
    "id": 192,
    "sortname": "SN",
    "name": "Senegal"
  },
  {
    "id": 193,
    "sortname": "RS",
    "name": "Serbia"
  },
  {
    "id": 194,
    "sortname": "SC",
    "name": "Seychelles"
  },
  {
    "id": 195,
    "sortname": "SL",
    "name": "Sierra Leone"
  },
  {
    "id": 196,
    "sortname": "SG",
    "name": "Singapore"
  },
  {
    "id": 197,
    "sortname": "SK",
    "name": "Slovakia"
  },
  {
    "id": 198,
    "sortname": "SI",
    "name": "Slovenia"
  },
  {
    "id": 199,
    "sortname": "XG",
    "name": "Smaller Territories of the UK"
  },
  {
    "id": 200,
    "sortname": "SB",
    "name": "Solomon Islands"
  },
  {
    "id": 201,
    "sortname": "SO",
    "name": "Somalia"
  },
  {
    "id": 202,
    "sortname": "ZA",
    "name": "South Africa"
  },
  {
    "id": 203,
    "sortname": "GS",
    "name": "South Georgia"
  },
  {
    "id": 204,
    "sortname": "SS",
    "name": "South Sudan"
  },
  {
    "id": 205,
    "sortname": "ES",
    "name": "Spain"
  },
  {
    "id": 206,
    "sortname": "LK",
    "name": "Sri Lanka"
  },
  {
    "id": 207,
    "sortname": "SD",
    "name": "Sudan"
  },
  {
    "id": 208,
    "sortname": "SR",
    "name": "Suriname"
  },
  {
    "id": 209,
    "sortname": "SJ",
    "name": "Svalbard And Jan Mayen Islands"
  },
  {
    "id": 210,
    "sortname": "SZ",
    "name": "Swaziland"
  },
  {
    "id": 211,
    "sortname": "SE",
    "name": "Sweden"
  },
  {
    "id": 212,
    "sortname": "CH",
    "name": "Switzerland"
  },
  {
    "id": 213,
    "sortname": "SY",
    "name": "Syria"
  },
  {
    "id": 214,
    "sortname": "TW",
    "name": "Taiwan"
  },
  {
    "id": 215,
    "sortname": "TJ",
    "name": "Tajikistan"
  },
  {
    "id": 216,
    "sortname": "TZ",
    "name": "Tanzania"
  },
  {
    "id": 217,
    "sortname": "TH",
    "name": "Thailand"
  },
  {
    "id": 218,
    "sortname": "TG",
    "name": "Togo"
  },
  {
    "id": 219,
    "sortname": "TK",
    "name": "Tokelau"
  },
  {
    "id": 220,
    "sortname": "TO",
    "name": "Tonga"
  },
  {
    "id": 221,
    "sortname": "TT",
    "name": "Trinidad And Tobago"
  },
  {
    "id": 222,
    "sortname": "TN",
    "name": "Tunisia"
  },
  {
    "id": 223,
    "sortname": "TR",
    "name": "Turkey"
  },
  {
    "id": 224,
    "sortname": "TM",
    "name": "Turkmenistan"
  },
  {
    "id": 225,
    "sortname": "TC",
    "name": "Turks And Caicos Islands"
  },
  {
    "id": 226,
    "sortname": "TV",
    "name": "Tuvalu"
  },
  {
    "id": 227,
    "sortname": "UG",
    "name": "Uganda"
  },
  {
    "id": 228,
    "sortname": "UA",
    "name": "Ukraine"
  },
  {
    "id": 229,
    "sortname": "AE",
    "name": "United Arab Emirates"
  },
  {
    "id": 230,
    "sortname": "GB",
    "name": "United Kingdom"
  },
  {
    "id": 231,
    "sortname": "US",
    "name": "United States"
  },
  {
    "id": 232,
    "sortname": "UM",
    "name": "United States Minor Outlying Islands"
  },
  {
    "id": 233,
    "sortname": "UY",
    "name": "Uruguay"
  },
  {
    "id": 234,
    "sortname": "UZ",
    "name": "Uzbekistan"
  },
  {
    "id": 235,
    "sortname": "VU",
    "name": "Vanuatu"
  },
  {
    "id": 236,
    "sortname": "VA",
    "name": "Vatican City State (Holy See)"
  },
  {
    "id": 237,
    "sortname": "VE",
    "name": "Venezuela"
  },
  {
    "id": 238,
    "sortname": "VN",
    "name": "Vietnam"
  },
  {
    "id": 239,
    "sortname": "VG",
    "name": "Virgin Islands (British)"
  },
  {
    "id": 240,
    "sortname": "VI",
    "name": "Virgin Islands (US)"
  },
  {
    "id": 241,
    "sortname": "WF",
    "name": "Wallis And Futuna Islands"
  },
  {
    "id": 242,
    "sortname": "EH",
    "name": "Western Sahara"
  },
  {
    "id": 243,
    "sortname": "YE",
    "name": "Yemen"
  },
  {
    "id": 244,
    "sortname": "YU",
    "name": "Yugoslavia"
  },
  {
    "id": 245,
    "sortname": "ZM",
    "name": "Zambia"
  },
  {
    "id": 246,
    "sortname": "ZW",
    "name": "Zimbabwe"
  }
];

class BankDetails{
  String id,accountNumber,bankName,ifscNumber,holderName,branchName,accountType,checkbook;
  BankDetails({
    required this.id,
    required this.accountNumber,
    required this.bankName,
    required this.ifscNumber,
    required this.holderName,
    required this.branchName,
    required this.accountType,
    required this.checkbook,
  });

  factory BankDetails.fromJson(Map json){
    return BankDetails(
        id: json["id"].toString(),
        accountNumber: json["acc_no"],
        bankName: json["bank_name"],
        ifscNumber: json["ifsc_no"],
        holderName: json["holder_name"],
        branchName: json["branch_name"],
        accountType: json["acc_type"],
        checkbook: ""
    );
  }
}
enum UserApprovalStatus{
  verified,
  unverified
}

enum UserActiveStatus {
  inactive,
  active
}

class UserModel {
  String id,name,email;
  ServiceModel? service;
  // personal details
  String? mobileno,landmark,state,city,zip,area,panCardNumber,callingNumber,kycNumber,gstNumber,kycType,houseNumber;
  Country? country;
  // office details
  String? officeNumber,officePhone, officeZip, officeArea, officeLandmark, officeState, officeCity ;
  Country? officeCountry;
  // Documents
  String? panCardUrl, kycUrl, gstUrl, dlUrl,vendorUrl ;
  BankDetails? bankDetails;
  UserApprovalStatus userStatus;
  RegisterProgress progress;
  UserActiveStatus userActiveStatus;
  UserModel({
   required this.id,
   required this.name,
   required this.email,
    required this.userStatus,
    required this.progress,
    required this.userActiveStatus,
    this.service,
   this.mobileno,
   this.country,
    this.state,
    this.city,
    this.zip,
    this.panCardNumber,
    this.callingNumber,
    this.landmark,
    this.area,
    this.houseNumber,
    this.kycType,
    this.kycNumber,
    this.gstNumber,
  //Office details
    this.officePhone,
    this.officeArea,
    this.officeCity,
    this.officeLandmark,
    this.officeNumber,
    this.officeState,
    this.officeZip,
    this.officeCountry,
  //Document details
    this.panCardUrl,
    this.gstUrl,
    this.kycUrl,
    this.vendorUrl,
    this.dlUrl,
    this.bankDetails

});

  factory UserModel.fromJson(Map json){
    BankDetails? details;
    RegisterProgress progress = RegisterProgress.two;
    ServiceModel? service = null;
    if (json["first_service"]!=null){
      service = ServiceModel.fromJson(json["first_service"]);
    }
    if(json["vendor_details"]==null){
      return UserModel(
        progress: progress,
        userStatus: json["data"]["status"]=="A"?UserApprovalStatus.verified:UserApprovalStatus.unverified,
        id: json["data"]["id"].toString(),
        name: json["data"]["name"].toString(),
        email: json["data"]["email"].toString(),
        mobileno: json["data"]["mobile"],
        country: json["data"]["country"],
        service: service,
        userActiveStatus: UserActiveStatus.active
      );
    }
    if(json["vendor_details"]["vendor_reg_part"]!=null){
      switch(json["vendor_details"]["vendor_reg_part"]){
        case 1:
          progress = RegisterProgress.one;
          break;
        case 2:
          progress = RegisterProgress.two;
          break;
        case 3:
          progress = RegisterProgress.three;
          break;
        case 4:
          progress = RegisterProgress.four;
          break;
        case 5:
          progress = RegisterProgress.five;
          break;
        case 6:
          progress = RegisterProgress.six;
          break;
        case 7:
          progress = RegisterProgress.completed;
      }
    }
    if(json["bank_details"]!=null){
      details = BankDetails.fromJson(json["bank_details"]);
    }
    return UserModel(
        userStatus: json["data"]["status"]=="A"?UserApprovalStatus.verified:UserApprovalStatus.unverified,
        id: json["data"]["id"].toString(),
      progress: progress,
      name: json["data"]["name"].toString(),
      email: json["data"]["email"].toString(),
      mobileno: json["data"]["mobile"],
      state: json["vendor_details"]["state"]??"Not set",
      city: json["vendor_details"]["city"],
      area: json["vendor_details"]["area"],
      zip: json["vendor_details"]["pin_code"],
      country: json["vendor_details"]["personal_country_name"]==null?Country(id: "101", name: "India"):Country.fromJson(json["vendor_details"]["personal_country_name"]),
      landmark: json["vendor_details"]["landmark"],
      panCardNumber: json["vendor_details"]["pan_card"],
      callingNumber: json["vendor_details"]["calling_no"],
      houseNumber: json["vendor_details"]["house_no"],
      kycNumber: json["vendor_details"]["kyc_no"],
      kycType: json["vendor_details"]["kyc_type"],
      gstNumber: json["vendor_details"]["gst_no"],
      officeZip: json["vendor_details"]["office_pincode"],
      officeNumber: json["vendor_details"]["office_house_no"],
      officePhone: json["vendor_details"]["office_mobile"]??"",
      officeArea: json["vendor_details"]["office_area"],
      officeLandmark: json["vendor_details"]["office_landmark"],
      officeCity: json["vendor_details"]["office_city"],
      officeState: json["vendor_details"]["office_state"],
      officeCountry: json["vendor_details"]["country_name"]!=null?Country.fromJson(json["vendor_details"]["country_name"]):null,
      panCardUrl: '${json["pan_image_link"]}${json["vendor_details"]["pan_image"]}',
      gstUrl: '${json["gst_image"]}${json["vendor_details"]["gst_image"]}',
      kycUrl: '${json["kyc_image"]}${json["vendor_details"]["kyc_image"]}',
      vendorUrl: '${json["vendor_image"]}${json["vendor_details"]["vendor_image"]}',
      dlUrl: '${json["dl_image"]}${json["vendor_details"]["dl_image"]}',
      bankDetails: details,
      service: service,
      userActiveStatus: json["data_active_inactive_del"]["Vendor_status"]!="I"?UserActiveStatus.active:UserActiveStatus.inactive
    );

  }
}
