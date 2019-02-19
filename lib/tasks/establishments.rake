require "nyc_geo_client"

namespace :establishments do
  desc "Load establishments from API, geocode, and store to db"
  task update_establishments: :environment do
    client = NYCGeoClient::Client.new(app_id: 'dc074185', app_key: '5538af0b4a556296c7b536df853f8697')
    response = Faraday.get "https://data.cityofnewyork.us/resource/9w7m-hzhe.json?$group=camis,building,street,zipcode,dba&$select=camis,building,street,zipcode,dba&$limit=50000"
    establishments = JSON.parse(response.body)

    establishments.each do |e_obj|
      existing = Establishment.find_by_camis(e_obj["camis"])
      next if existing
      e = Establishment.new camis: e_obj["camis"], dba: e_obj["dba"], address: [e_obj["building"], e_obj["street"], e_obj["zipcode"]].join(" ")
      location = client.address(house_number: e_obj["building"], street: e_obj["street"], borough: e_obj["boro"], zip: e_obj["zipcode"])

      if location && location["address"] && location["address"]["latitude"] && location["address"]["longitude"]
        e.location = "POINT(#{location["address"]["longitude"]} #{location["address"]["latitude"]})"
        if e.save
          Rails.logger.info "Saved #{e.inspect} successfully"
        else
          Rails.logger.info "Failed to save #{e.inspect}"
        end

      else
        Rails.logger.info "Failed to geocode #{e_obj.inspect}"
        next
      end
    end
  end

end
