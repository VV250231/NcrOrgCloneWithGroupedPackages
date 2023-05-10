global class JP_Mock_Service implements HttpCalloutMock {
    
    
    global static HttpResponse respond(HttpRequest hreq) {
        HttpResponse hresp  = new HttpResponse() ;
        hresp.setStatusCode(200) ;
        hresp.setStatus('SUCCESS') ;
        hresp.setBody('{'+
   ' "interactiveQuestionsExpected": true,'+
   ' "customFields": [     '+   
    '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "legal.address",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "dba.name",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexAuthFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AuthFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.cvv2",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                                             '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.monthlyminimum",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.applicationfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.helpdeskfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.annualfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.GatewayMonthly",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.MonthlyMaint",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                    '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.PCIMonthly",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.GatewayPerTrans",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                                       '  {'+
    ' "Id": 5977,'+
     '"Prompt": "Test",'+
       ' "ShortName": "Test",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.annualPCI",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                       
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.SettleFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                       
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexAuthFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                       
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.ACHProcessingTrans",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
	   
	    '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.pricingtype",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                
					'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexSettleFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
	   
			
					'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.Chargebacks",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
	   
			
					'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.Retrievals",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			
					'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AcctUpdaterPerSuccess",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AcctUpdaterPerTxn",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AVS",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.BatchFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.reportingfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.acctsetupfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.MerlinkCBs",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.NSF",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.DebitAuthFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.PINDebitAccessFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.pricingtype",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "salesrep.email",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "SF.MCN",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+

			 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "number.sites",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+

			 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexPT",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+

			 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.visapt",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+

		 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexMID",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                 
				 
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexNonQual",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.VisaQual",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.VisaMID",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.VisaNonQual",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.RegCompliance",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.PCINonCompliance",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.ACHBatchFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
				
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AcctUpdaterMonthly",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
			
                 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "annual.volume",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "sf.siteid",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "sf.salesprogram",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "sf.paymentsalesrep",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "sf.opportunity",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "sf.opportunityURL",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.ebtmonthlyaccessfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.ebtpertransactionfee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "salesrep.name",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "salesrep.email",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                    '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "agent.accounttype",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
				
                  '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "product.type",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "annual.transactions",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			
				 '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.AmexQual",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
	
		
	   '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "dba.address",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                          '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "dba.email",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "dba.phone",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
			'  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "legal.name",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' },'+
                      '  {'+
    ' "Id": 5977,'+
     '"Prompt": "MCC Code* (Verify that the business type entered most accurately matches your business)",'+
       ' "ShortName": "MCC Code",'+
       '     "FieldType": "select",'+
         '   "PlaceholderText": "",'+
          '  "IsRequired": true,'+
          /* ' "OptionsList": ['+
              ' "Bars, Cocktail Lounges, Discotheques, Nightclubs and Taverns–Drinking Places/Alcoholic Beverages\t5813",'+
               ' "Caterers (banquite, caterer, food)\t5811",'+
               ' "Eating Places, Restaurants\t5812",'+
                'Fast Food Restaurants\t5814",'+
               ' "Misc and Speciality retails stores\t5999"'+
           ' ],'+*/
          '  "ValuesList": ['+
               ' "5813",'+
               ' "5811",'+
               ' "5812",'+
               ' "5814",'+
               ' "5999"'+
           ' ],'+
           ' "StepNumber": 1,'+
           ' "UserDefinedId": "pricing.ACHReturnFee",'+
           ' "OrderingIndex": 900,'+
           ' "ResponseValueKeys": ['+
           '     "#"'+
           ' ]'+

       ' }'+
	'	        ]'+
   ' }') ;
        
        return hresp ;
        
        
    }
    
    
}