component extends="testbox.system.BaseSpec"{

    function setup(){


        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "GeoService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.random = new tests.utils.RandomData();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function get_test(){

        var randCity = variables.random.getCities(limit = 1);

        var city = variables.svc.getCity( cityId = randCity.city_id.toString() );

        $assert.isTrue( 
            ( city.getId() EQ randCity.city_id.toString() ) 
            AND ( city.getName() EQ randCity.city ) 
            AND ( city.getCounty().getId() EQ randCity.county_id ) 
            AND ( city.getCounty().getState().getId() EQ randCity.state_id.toString() ) 
            AND ( city.getCounty().getState().getCountry().getId() EQ randCity.country_id.toString() ) 

        );
                
    }

    function search_test(){

        var limit = 10;
  
        var result = variables.svc.searchCities( 
            str = 'Ba',
            countyId = 'NA',
            countryId =  '693a3dda-bf35-4556-9a12-2c693afce836', //italia
            //stateId   = 'RG4',
            limit = limit
         );

         $assert.isTrue( 
            ( limit GTE result.getCount() ) 
        );

    }


}