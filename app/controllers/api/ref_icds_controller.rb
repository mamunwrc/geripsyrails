class Api::RefIcdsController < Api::BaseController
  def index
    respond_with Ref::Icd.sorted_actives.map {|icd|
      {keyname: icd.icd, keyvalue: [icd.icd, icd.description].join(" - ")}
    }
  end
end
