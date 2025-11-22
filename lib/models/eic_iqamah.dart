class EICIqamah {
  String? dateInput;
  String? salatDate;
  String? fajrStart;
  String? fajr;
  String? fajrStop;
  String? duhrStart;
  String? duhr;
  String? duhrStop;
  String? asrStart;
  String? asr;
  String? asrStop;
  String? maghribStart;
  String? maghrib;
  String? maghribStop;
  String? ishaStart;
  String? isha;
  String? ishaStop;
  String? jummah1;
  String? jummah2;
  String? jummah3;
  String? jummahKhateeb1;
  String? jummahKhateeb2;
  String? jummahKhateeb3;
  String? noticesText;
  List<String>? notices;
  String? eventsText;
  List<String>? events = [];
  String? hijriMonth;
  int? hijriDay;
  int? hijriYear;
  OtherSalah? otherSalah;
  String? bannerLine1;
  String? bannerLine2;

  EICIqamah(
      {this.dateInput,
      this.salatDate,
      this.fajrStart,
      this.fajr,
      this.fajrStop,
      this.duhrStart,
      this.duhr,
      this.duhrStop,
      this.asrStart,
      this.asr,
      this.asrStop,
      this.maghribStart,
      this.maghrib,
      this.maghribStop,
      this.ishaStart,
      this.isha,
      this.ishaStop,
      this.jummah1,
      this.jummah2,
      this.jummah3,
      this.jummahKhateeb1,
      this.jummahKhateeb2,
      this.jummahKhateeb3,
      this.noticesText,
      this.notices,
      this.eventsText,
      this.events,
      this.hijriMonth,
      this.hijriDay,
      this.hijriYear,
      this.otherSalah,
      this.bannerLine1,
      this.bannerLine2});

  EICIqamah.fromJson(Map<String, dynamic> json) {
    dateInput = json['date_input'];
    salatDate = json['salat_date'];
    fajrStart = json['fajr_start'];
    fajr = json['fajr'];
    fajrStop = json['fajr_stop'];
    duhrStart = json['duhr_start'];
    duhr = json['duhr'];
    duhrStop = json['duhr_stop'];
    asrStart = json['asr_start'];
    asr = json['asr'];
    asrStop = json['asr_stop'];
    maghribStart = json['maghrib_start'];
    maghrib = json['maghrib'];
    maghribStop = json['maghrib_stop'];
    ishaStart = json['isha_start'];
    isha = json['isha'];
    ishaStop = json['isha_stop'];
    jummah1 = json['jummah1'];
    jummah2 = json['jummah2'];
    jummah3 = json['jummah3'];
    jummahKhateeb1 = json['jummah_khateeb1'];
    jummahKhateeb2 = json['jummah_khateeb2'];
    jummahKhateeb3 = json['jummah_khateeb3'];
    noticesText = json['notices_text'];
    notices = json['notices'].cast<String>();
    eventsText = json['events_text'];
    events = json['events'].cast<String>();
    hijriMonth = json['hijri_month'];
    hijriDay = json['hijri_day'];
    hijriYear = json['hijri_year'];
    otherSalah = json['other_salah'] != null
        ? OtherSalah.fromJson(json['other_salah'])
        : null;
    bannerLine1 = json['bannerLine1'];
    bannerLine2 = json['bannerLine2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date_input'] = dateInput;
    data['salat_date'] = salatDate;
    data['fajr_start'] = fajrStart;
    data['fajr'] = fajr;
    data['fajr_stop'] = fajrStop;
    data['duhr_start'] = duhrStart;
    data['duhr'] = duhr;
    data['duhr_stop'] = duhrStop;
    data['asr_start'] = asrStart;
    data['asr'] = asr;
    data['asr_stop'] = asrStop;
    data['maghrib_start'] = maghribStart;
    data['maghrib'] = maghrib;
    data['maghrib_stop'] = maghribStop;
    data['isha_start'] = ishaStart;
    data['isha'] = isha;
    data['isha_stop'] = ishaStop;
    data['jummah1'] = jummah1;
    data['jummah2'] = jummah2;
    data['jummah3'] = jummah3;
    data['jummah_khateeb1'] = jummahKhateeb1;
    data['jummah_khateeb2'] = jummahKhateeb2;
    data['jummah_khateeb3'] = jummahKhateeb3;
    data['notices_text'] = noticesText;
    data['notices'] = notices;
    data['events_text'] = eventsText;
    data['events'] = events;
    data['hijri_month'] = hijriMonth;
    data['hijri_day'] = hijriDay;
    data['hijri_year'] = hijriYear;
    if (otherSalah != null) {
      data['other_salah'] = otherSalah!.toJson();
    }
    data['bannerLine1'] = bannerLine1;
    data['bannerLine2'] = bannerLine2;
    return data;
  }
}

class OtherSalah {
  String? shurooq;
  String? ishraq;
  String? chasath;

  OtherSalah({this.shurooq, this.ishraq, this.chasath});

  OtherSalah.fromJson(Map<String, dynamic> json) {
    shurooq = json['shurooq'];
    ishraq = json['ishraq'];
    chasath = json['chasath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shurooq'] = shurooq;
    data['ishraq'] = ishraq;
    data['chasath'] = chasath;
    return data;
  }
}
