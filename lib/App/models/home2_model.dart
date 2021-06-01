class FieldDataModel {
  FieldData fieldData;
  dynamic recordId;
  dynamic modId;

  FieldDataModel({this.fieldData, this.recordId, this.modId});

  FieldDataModel.fromJson(Map<dynamic, dynamic> json) {
    fieldData = json['fieldData'] != null
        ? new FieldData.fromJson(json['fieldData'])
        : null;
    recordId = json['recordId'];
    modId = json['modId'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.fieldData != null) {
      data['fieldData'] = this.fieldData.toJson();
    }
    data['recordId'] = this.recordId;
    data['modId'] = this.modId;
    return data;
  }
}

class FieldData {
  dynamic locationId;
  dynamic fkUniqueId;
  dynamic fullName;
  dynamic leaderName;
  dynamic gathering;
  dynamic unHabbitation;
  dynamic village;
  dynamic colony;
  dynamic block;
  dynamic district;
  dynamic state;
  dynamic gatheringImage;
  dynamic familyImage;
  dynamic leaderImage;
  dynamic communityImage;
  dynamic vCHU;
  dynamic location;
  dynamic status;

  FieldData(
      {this.locationId,
      this.fkUniqueId,
      this.fullName,
      this.leaderName,
      this.gathering,
      this.unHabbitation,
      this.village,
      this.colony,
      this.block,
      this.district,
      this.state,
      this.gatheringImage,
      this.familyImage,
      this.leaderImage,
      this.communityImage,
      this.vCHU,
      this.location,
      this.status});

  FieldData.fromJson(Map<dynamic, dynamic> json) {
    locationId = json['Location_id'];
    fkUniqueId = json['Fk_unique_id'];
    fullName = json['Full_name'];
    leaderName = json['Leader_name'];
    gathering = json['Gathering'];
    unHabbitation = json['Un_habbitation'];
    village = json['Village'];
    colony = json['Colony'];
    block = json['Block'];
    district = json['District'];
    state = json['State'];
    gatheringImage = json['Gathering_image'];
    familyImage = json['Family_image'];
    leaderImage = json['Leader_image'];
    communityImage = json['Community_image'];
    vCHU = json['VCHU'];
    location = json['Location'];
    status = json['status'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['Location_id'] = this.locationId;
    data['Fk_unique_id'] = this.fkUniqueId;
    data['Full_name'] = this.fullName;
    data['Leader_name'] = this.leaderName;
    data['Gathering'] = this.gathering;
    data['Un_habbitation'] = this.unHabbitation;
    data['Village'] = this.village;
    data['Colony'] = this.colony;
    data['Block'] = this.block;
    data['District'] = this.district;
    data['State'] = this.state;
    data['Gathering_image'] = this.gatheringImage;
    data['Family_image'] = this.familyImage;
    data['Leader_image'] = this.leaderImage;
    data['Community_image'] = this.communityImage;
    data['VCHU'] = this.vCHU;
    data['Location'] = this.location;
    data['status'] = this.status;
    return data;
  }
}
