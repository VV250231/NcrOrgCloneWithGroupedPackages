({
    prepareTableHelper: function(component, event, helper, operationType ) {
        //Event to pass record id for ValidateEddEbd modal
       
        $A.get("e.c:PassRecordIdEvent").setParams({
            "passRecordId" : component.get("v.OppId"),
            "callFromSelectPage":false
        }).fire();
        
        //End of Event to pass record id for ValidateEddEbd modal
        var action = component.get("c.getData");   
        action.setParams({
            OppId : component.get("v.OppId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(response.getReturnValue().length==0){ 		
                this.getOpportunityById(component, event, helper); 		
                console.log( this.getOpportunityById(component, event, helper) );
                component.set("v.toggleSpinner","false");
                component.set("v.anyCloudProduct" , false) ;
                component.set("v.anyNonCloudProduct" , false) ;
                //added by Satyam
                component.set("v.anySubscrProd", false);
                component.set("v.anyNonSubscrProd", false);
                component.set("v.dataList",[]);
                
                
                
            }
            if(state === 'SUCCESS' && response.getReturnValue().length>0){                
                var retResponse = response.getReturnValue();   
                //alert(JSON.stringify(retResponse));
                console.log('@@##'+ JSON.stringify(retResponse) );
                var uniqueDateTableHeaderSet = new Set();
                var DateTableHeader = [];
                /********************************************************************************************
                    //Static Map for getting month
                    ********************************************************************************************/
                var convertingMonth = {
                    1: 'Jan',
                    2: 'Feb',
                    3: 'Mar',
                    4: 'Apr', 
                    5: 'May',
                    6: 'Jun',
                    7: 'Jul',
                    8: 'Aug',
                    9: 'Sep',
                    10: 'Oct',
                    11: 'Nov',
                    12: 'Dec'
                };
                /********************************************************************************************
                    //getting Month & Year from Schedules and populateing them in set for removing duplicates
                    ********************************************************************************************/
                var EDD;
                var EBD;
                var OppName;
                var OppCurr;
                var IsClosed ;
                for( var i=0; i < retResponse.length ; i++ ){
                    EDD = retResponse[i].EDD;
                    EBD = retResponse[i].EBD;
                    IsClosed = retResponse[i].IsClosed;
                    OppName = retResponse[i].Name; 
                    OppCurr = retResponse[i].Currenci; 
                    console.log(OppCurr);
                    for( var j=0; j < retResponse[i].ISWList.length ; j++ ){						                        
                        if( retResponse[i].ISWList[j].schMonth != null && retResponse[i].ISWList[j].schYear != null ){
                            var concateMonthYear = convertingMonth[ retResponse[i].ISWList[j].schMonth ]+'-'+retResponse[i].ISWList[j].schYear;
                            uniqueDateTableHeaderSet.add(concateMonthYear);
                        }
                    }
                }
                component.set("v.EDD",EDD);
                component.set("v.EBD",EBD);
                component.set("v.OppName",OppName);
                component.set("v.OppCurr",OppCurr);
                component.set("v.ToggleReadOnly",IsClosed);                
                component.set("v.disableEdit",IsClosed);
                
                /********************************************************************************************
                    //To give warning message, if Opportunity is closed @ Read-Only Page - sk250817
                    ********************************************************************************************/
                if(IsClosed){
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Warning ! Opportunity changes are not allowed after an opportunity has been closed. Please contact NSC Administrator using the Need Help button if you need to re-open or to make changes to this opportunity.",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire(); 
                }
                /********************************************************************************************
                    //Loop on set with unique value and assigning it in itratable variable
                    ********************************************************************************************/
                for ( let item of uniqueDateTableHeaderSet ){
                    DateTableHeader.push(
                        {
                            label:item,
                            style:'background-color: rgb(75, 202, 129);color:#FFFFFF;font-weight:bold'
                        }
                    );
                }
                /********************************************************************************************
                    //Setting the value in aura:attribute
                    ********************************************************************************************/
                var monthNames = {
                    'Jan'  :1, 
                    'Feb'  :2, 
                    'Mar'  :3, 
                    'Apr'  :4, 
                    'May'  :5, 
                    'Jun'  :6, 
                    'Jul'  :7, 
                    'Aug'  :8, 
                    'Sep'  :9, 
                    'Oct'  :10,
                    'Nov'  :11,
                    'Dec'  :12
                }; 
                //SORTING HEADER
                DateTableHeader = DateTableHeader.sort(function(a, b) {				 
                    a = a['label'].split("-");
                    b = b['label'].split("-");
                    return new Date(a[1], monthNames[a[0]], 1) - new Date(b[1], monthNames[b[0]], 1);                
                });
                //SORTING HEADER
                component.set("v.scheduleHeader",DateTableHeader);
                
                /********************************************************************************************
                    //Putting Actul data in object
                    ********************************************************************************************/
                var dataObj = [];
                var MapCounterToSchQty=[];
                var ShowtoggleModal = false;
                var showCloudProducts = false ;
                var showNonCloudProducts = false ;
                var showSubscriptionSect = false;
                var ShowNonSubscriptionProducts = false;
                
                for( var i=0; i < retResponse.length ; i++ ){  
                    console.log(retResponse[i]);
                    if(retResponse[i].PW.Unscheduled_Quantity>0){
                        ShowtoggleModal =true;
                    }
                    if(retResponse[i].PW.isSubscriptioned == true || retResponse[i].PW.RevenueType=='Cloud') {
                        showCloudProducts = true ;
                    }
                    if(retResponse[i].PW.isSubscriptioned == false )  {
                        showNonCloudProducts = true ;
                    } 
                     //added by Satyam
                     if(retResponse[i].PW.isSubscriptioned == true || component.get("v.subsOnlyRevenueTypes").includes(retResponse[i].PW.RevenueType) || component.get("v.subsOnlyProdNames").includes(retResponse[i].PW.Name) || retResponse[i].PW.isCATMProduct == true) {
                          showSubscriptionSect = true;
                        console.log('_____showSubscriptionSect --'+showSubscriptionSect+'__prod Name__'+retResponse[i].PW.Name);
                     }
                       if(retResponse[i].PW.isSubscriptioned == false &&  !component.get("v.subsOnlyProdNames").includes(retResponse[i].PW.Name) && !component.get("v.subsOnlyRevenueTypes").includes(retResponse[i].PW.RevenueType) && retResponse[i].PW.isCATMProduct == false)  {
                        ShowNonSubscriptionProducts = true;
                        //console.log('_____ShowNonSubscriptionProducts___'+ShowNonSubscriptionProducts+'__prod Name__'+retResponse[i].PW.Name);
                    }
                    /*if(retResponse[i].PW.isPackage == true && $A.util.isEmpty(retResponse[i].PW.MasterLineId)){ 
                        component.set("v.packageCount", component.get("v.packageCount")+1);
                    } */
                   
                  
                    dataObj.push(
                        {
                            Counter : i,
                            productID:retResponse[i].PW.productID,
                            Name:retResponse[i].PW.Name,
                            UnitPrice:retResponse[i].PW.UnitPrice,
                            Quantity:retResponse[i].PW.Quantity,
                            //Quantity:retResponse[i].PW.Quantity,
                            TotalPrice:retResponse[i].PW.TotalPrice,
                            //done by sushant
                            TotalTCVPrice:retResponse[i].PW.TotalTCVPrice==null?0:retResponse[i].PW.TotalTCVPrice,
                            TotalACVPrice:retResponse[i].PW.TotalACVPrice==null?0:retResponse[i].PW.TotalACVPrice,
                            NumberOfTerms:retResponse[i].PW.NumberOfTerms==null?0:retResponse[i].PW.NumberOfTerms,
                            OneTimeFee:retResponse[i].PW.OneTimeFee==null?0:retResponse[i].PW.OneTimeFee,
                            MonthlyFee:retResponse[i].PW.MonthlyFee==null?0:retResponse[i].PW.MonthlyFee,
                            mandateSubscriptioned:component.get("v.subsOnlyProdNames").includes(retResponse[i].PW.Name)== true || component.get("v.subsOnlyRevenueTypes").includes(retResponse[i].PW.RevenueType)== true?true:false,
                            //done by sushant end
                            Unscheduled_Quantity:retResponse[i].PW.Unscheduled_Quantity,
                            NumberOfLicense:retResponse[i].PW.NumberOfLicense,
                            // Unscheduled_Quantity:retResponse[i].PW.isPackage == true ? retResponse[i].PW.Unscheduled_Quantity/retResponse[i].PW.NumberOfLicense:retResponse[i].PW.Unscheduled_Quantity,
                            
                            //Unscheduled_Quantity:retResponse[i].PW.isPackage == true ? (retResponse[i].PW.Unscheduled_Quantity/retResponse[i].PW.NumberOfLicense)==null?0:
                            //retResponse[i].PW.Unscheduled_Quantity/retResponse[i].PW.NumberOfLicense:retResponse[i].PW.Unscheduled_Quantity,
                            
                            UnchStyleClass : retResponse[i].PW.UnchStyleClass,
                            RevenueType : retResponse[i].PW.RevenueType ,
                            isSubscriptioned : retResponse[i].PW.isSubscriptioned  ,
                            LeadTime_Wks:retResponse[i].PW.LeadTime_Wks,
                            qtyTyp:retResponse[i].PW.qtyTyp, 
                            isCATMProduct : retResponse[i].PW.isCATMProduct, 
                            //Subscription Package 
                            /*Source : retResponse[i].PW.Source,
                            isPackage:retResponse[i].PW.isPackage,
                            isCompanion:retResponse[i].PW.isCompanion,
                            NumberOfLicense:retResponse[i].PW.NumberOfLicense,
                            NumberOfSite:retResponse[i].PW.NumberOfSites,
                            MasterLineId:retResponse[i].PW.MasterLineId, */
                            Schedules:[]
                        }
                    );
                    //List for holding Index and Total Schedule Qty
                    MapCounterToSchQty.push({
                        key:i,
                        ScheduledQty: retResponse[i].PW.Quantity - retResponse[i].PW.Unscheduled_Quantity
                    });
                    for( var j=0; j < retResponse[i].ISWList.length ; j++ ){
                        if( dataObj[i].productID == retResponse[i].ISWList[j].productID ){
                            dataObj[i].Schedules.push(
                                {
                                    ScheduleID:retResponse[i].ISWList[j].ScheduleID,
                                    Quantity:retResponse[i].ISWList[j].Quantity,
                                    productID:retResponse[i].ISWList[j].productID,
                                    schLabel:convertingMonth[ retResponse[i].ISWList[j].schMonth ]+'-'+retResponse[i].ISWList[j].schYear
                                }
                            );    
                        }
                    }                    
                }
                
                // component.set("v.anyCloudProduct" , showCloudProducts) ;
                component.set("v.anySubscrProd",showSubscriptionSect);
               // component.set("v.anyNonCloudProduct" , showNonCloudProducts) ;
                component.set("v.anyNonSubscrProd",ShowNonSubscriptionProducts);
                /********************************************************************************************
                    //Putting dummy data in object                
                    ********************************************************************************************/                
                for( var x=0; x < dataObj.length ; x++ ){
                    console.log('%%%%%'+ JSON.stringify(dataObj[x].Schedules ));
                    var str=JSON.stringify(dataObj[x].Schedules );
                    for( var y=0; y < DateTableHeader.length ; y++ ){
                        if( dataObj[x].Schedules.length != DateTableHeader.length ){
                            if(!str.includes(DateTableHeader[y].label)){dataObj[x].Schedules.push(
                                
                                {
                                    ScheduleID:'',
                                    Quantity:null,
                                    productID:dataObj[x].productID,
                                    schLabel:DateTableHeader[y].label
                                }
                            );
                                                                       }
                            
                        }
                    }
                }
                //console.log('%%%%%'+ JSON.stringify(dataObj ));
                //SORTING DATA
                for( var x=0; x < dataObj.length ; x++ ){
                    dataObj[x].Schedules = dataObj[x].Schedules.sort(function(a, b) {				 
                        a = a['schLabel'].split("-");
                        b = b['schLabel'].split("-");
                        return new Date(a[1], monthNames[a[0]], 1) - new Date(b[1], monthNames[b[0]], 1);                
                    });
                }
                //SORTING DATA
                
                //Start of show modal if product has atleast 1 Qty
                var today = component.get("v.todayDateVal") ;
                var EDSDate = new Date(component.get("v.EDD"));
                var ecxpectedBookDate = new Date(EBD);
                if(ecxpectedBookDate >= today && EDSDate > ecxpectedBookDate && operationType == 'DeleteProd'){
                    
                    if(ShowtoggleModal){
                        
                        component.set("v.toggleModal",ShowtoggleModal);  
                    } 
                }
                //End of show modal if product has atleast 1 Qty
                component.set("v.dataList",dataObj);
                this.calcTotalTCV(component);
                component.set("v.toggleSpinner","false");
                component.set("v.MapCounterToSchQty",MapCounterToSchQty);
                console.log( 'sks '+JSON.stringify(component.get("v.dataList" )));
                /********************************************************************************************
                    //Month Year MODAL 
                    ********************************************************************************************/
                var EDD = component.get( "v.EBD" );
                var today = new Date();
                var yearObj = [];
                //var EDDMonth = EDD.getMonth() + 1;
                var EDDMonth = new Date(EDD).getMonth() + 1;
                var EDDYear = new Date(EDD).getFullYear();
                var convertingMonth = {
                    1: 'Jan',
                    2: 'Feb',
                    3: 'Mar',
                    4: 'Apr',
                    5: 'May',
                    6: 'Jun',
                    7: 'Jul',
                    8: 'Aug',
                    9: 'Sep',
                    10: 'Oct',
                    11: 'Nov',
                    12: 'Dec'
                };
                var alreadySelected = component.get( "v.scheduleHeader" );                  
                var tempArr = [];
                for( var i=0; i < alreadySelected.length ; i++ ){
                    tempArr.push( alreadySelected[i].label );
                }
                
                var calenderCount = component.get( "v.calenderCount" );
                //for( var i=0; i < 5 ; i++ ){ 
                for( var i=0; i < calenderCount ; i++ ){ 
                    
                    yearObj.push(
                        {
                            //year:today.getFullYear() + i,
                            year:EDDYear + i,
                            month:[]
                        }
                    );
                    for ( var key in convertingMonth ) {
                        yearObj[i].month.push(
                            { 
                                label:convertingMonth[key],
                                id:convertingMonth[key]+'-'+(EDDYear + i),
                                disable:( EDDMonth > key && EDDYear + i == EDDYear ? true : false),
                                selected:tempArr.includes( convertingMonth[key]+'-'+(EDDYear + i) ),
                                access : EDDMonth > key && EDDYear + i == EDDYear ? 'Not Available' : tempArr.includes( convertingMonth[key]+'-'+(today.getFullYear() + i) ) ? 'Selected' : 'Select'
                                
                            }
                        );
                    }            
                }
                component.set( "v.MonthData",yearObj );
            }else if (state === "ERROR") {
                console.log('Error');
            }
            // Ajay set total Page
            console.log('called');
            if(!component.get("v.ToggleReadOnly")){
                var self = this;
                setTimeout(function() {
                    self.setTotalPage(component, event, helper);
                }, 1000); 
            }
        });
        
        $A.enqueueAction(action);
        
        helper.checkschedules(component, event, helper) ;  
        
    },
    RePrepareTableHelper: function(component, event, NewProductIds) {  
        var backupList=new Array();
        backupList =component.get("v.dataList");
        var backupMapCounterToSchQty=new Array();
        backupMapCounterToSchQty=component.get("v.MapCounterToSchQty");
        var newMapCounterToSchQty=[];
        
        var dataObj1 = [];
        var pre_CloudProducts = component.get("v.anyCloudProduct") ;
        var pre_NonCloudProducts = component.get("v.anyNonCloudProduct") ;
        var showCloudProducts = false ;
        var showNonCloudProducts = false ;
        //added by Satyam
        var pre_SubsProducts = component.get("v.anySubscrProd") ;
        var pre_NonSubsProducts = component.get("v.anyNonSubscrProd") ;
        //added by Satyam
        var showSubscriProds = false;
        var showNonSubscriProds = false;
        for(var k=0; k <NewProductIds.length ; k++){
            if(NewProductIds[k].isSubscriptioned == true || NewProductIds[k].RevenueType == 'Cloud') {
                showCloudProducts = true ;
            }
            if(NewProductIds[k].isSubscriptioned == false && NewProductIds[k].RevenueType != 'Cloud')  {
                showNonCloudProducts = true  ;
            }
            if(NewProductIds[k].isSubscriptioned == true || component.get("v.subsOnlyProdNames").includes(NewProductIds[k].Name) || component.get("v.subsOnlyRevenueTypes").includes(NewProductIds[k].RevenueType) || NewProductIds[k].isCATMProduct == true) {
             showSubscriProds = true   
            }
            if(NewProductIds[k].isSubscriptioned == false &&  !component.get("v.subsOnlyProdNames").includes(NewProductIds[k].Name) && !component.get("v.subsOnlyRevenueTypes").includes(NewProductIds[k].RevenueType) && NewProductIds[k].isCATMProduct == false)  {
                //alert('___'+NewProductIds[k].Name+'___issubs'+NewProductIds[k].isSubscriptioned+'___includename'+ !component.get("v.subsOnlyProdNames").includes(NewProductIds[k].Name)+'___incudereve'+!component.get("v.subsOnlyRevenueTypes").includes(NewProductIds[k].RevenueType));
                        showNonSubscriProds = true;
                       
                    }
             var oppMonths = (component.get("v.isCatm") ? component.get("v.oppMonths") : NewProductIds[k].NumberOfTerms); 
            //console.log('___showSubscriProds___'+showSubscriProds+'____showNonSubscriProds___'+showNonSubscriProds);
            //console.log('__'+NewProductIds[k].Name);
            dataObj1.push(
                {
                    Counter : backupList.length+k,
                    productID:NewProductIds[k].productID,
                    Name:NewProductIds[k].Name,
                    UnitPrice:NewProductIds[k].UnitPrice,
                    //Quantity:NewProductIds[k].Quantity,
                    Quantity:NewProductIds[k].Quantity,
                    TotalPrice:NewProductIds[k].TotalPrice,
                    //done by sushant
                    TotalACVPrice:NewProductIds[k].TotalACVPrice,
                    TotalTCVPrice:NewProductIds[k].TotalTCVPrice,
                    NumberOfTerms:oppMonths,
                    OneTimeFee:NewProductIds[k].OneTimeFee,
                    MonthlyFee:NewProductIds[k].MonthlyFee,
                     mandateSubscriptioned:component.get("v.subsOnlyProdNames").includes(NewProductIds[k].Name)== true || component.get("v.subsOnlyRevenueTypes").includes(NewProductIds[k].RevenueType)== true?true:false,
                    //done by sushant ends
                    Unscheduled_Quantity:NewProductIds[k].Unscheduled_Quantity,
                    UnchStyleClass : NewProductIds[k].UnchStyleClass,
                    RevenueType : NewProductIds[k].RevenueType ,
                    isSubscriptioned : NewProductIds[k].isSubscriptioned ,
                    qtyTyp : NewProductIds[k].qtyTyp ,
                    isCATMProduct : NewProductIds[k].isCATMProduct, 
                    //Subscription Package 
                    /*isPackage:NewProductIds[k].isPackage,
                    isCompanion:NewProductIds[k].isCompanion,
                    NumberOfLicense:NewProductIds[k].NumberOfLicense,
                    NumberOfSite:NewProductIds[k].NumberOfSites,
                    MasterLineId:NewProductIds[k].MasterLineId,*/
                    Schedules:[]
                }
            );
            newMapCounterToSchQty.push({
                key:backupList.length+k,
                ScheduledQty: 0
            });
            for( var y=0; y < component.get("v.scheduleHeader").length ; y++ ){
                if( dataObj1[k].Schedules.length != component.get("v.scheduleHeader").length ){
                    dataObj1[k].Schedules.push(
                        {
                            ScheduleID:'',
                            Quantity:null,
                            productID:dataObj1[k].productID,
                            schLabel:component.get("v.scheduleHeader")[y].label
                        }
                    );
                }
            }
            
        }
        component.set("v.anyCloudProduct" , ( showCloudProducts || pre_CloudProducts ) ) ;
        component.set("v.anyNonCloudProduct" ,  ( pre_NonCloudProducts || showNonCloudProducts  ) )  ;
        //added by Satyam
        component.set("v.anySubscrProd" , ( showSubscriProds || pre_SubsProducts ) ) ;
        component.set("v.anyNonSubscrProd" ,  ( showNonSubscriProds || pre_NonSubsProducts  ) )  ;
        
        var dataObjFinal = [];
        var dataObjFinal = backupList.concat(dataObj1);        
        component.set("v.dataList",dataObjFinal);
        this.calcTotalTCV(component);
        component.set("v.MapCounterToSchQty",backupMapCounterToSchQty.concat(newMapCounterToSchQty));
    },
    ToggleAdjustHelper: function(component, event, helper) { 
        var getAllId = component.find("Chk"); 
        
        if(!$A.util.isEmpty(getAllId) && (component.get("v.dataList").length == 1 || $A.util.isEmpty(getAllId.length))  ){
            if(component.find( "Chk" )[0]){
                if( component.find( "Chk" )[0].get( "v.value" ) == true ){
                    component.set("v.TOGGLEDELETE",false);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.removeClass(cmpTarget, 'CursorCustom');
                }else{
                    /* by stuti changed logic from cloud to subscription as a part of EBA 2175 from line 457 */
                    //if(component.get("v.anyCloudProduct") == true && component.get("v.anyNonCloudProduct") == false){
                    if(component.get("v.anySubscrProd") == true && component.get("v.anyNonSubscrProd") == false){
                        /*** by Stuti EBA 2175 ends ***/
                        component.find("chkAll_Cloud").set("v.value",false);
                    }
                    else
                        component.find("chkAll").set("v.value",false);
                    component.set("v.TOGGLEDELETE",true);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.addClass(cmpTarget, 'CursorCustom');
                }
            }else{
                if( component.find( "Chk" ).get( "v.value" ) == true ){
                    component.set("v.TOGGLEDELETE",false);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.removeClass(cmpTarget, 'CursorCustom');
                }else{
                    if((component.get("v.anySubscrProd") == true)  && component.get("v.anyNonSubscrProd") == false) 
                        component.find("chkAll_Cloud").set("v.value",false);
                    else
                        component.find("chkAll").set("v.value",false);
                    component.set("v.TOGGLEDELETE",true);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.addClass(cmpTarget, 'CursorCustom');
                }
            }
            
        }
        else if( component.get("v.dataList").length > 1 ){
            var count = 0;
            for ( var i = 0; i < getAllId.length; i++ ) {
                if( component.find( "Chk" )[i].get( "v.value" ) == true ){
                    count = count + 1;
                }else{
                    if(component.get("v.anySubscrProd") == true && component.get("v.anyNonSubscrProd") == false) 
                        component.find("chkAll_Cloud").set("v.value",false);
                    else
                        component.find("chkAll").set("v.value",false);
                    // component.find("chkAll").set("v.value",false);
                }
            }
            
            if( count < 1 ){                
                component.set("v.TOGGLEDELETE",true);
                var cmpTarget = component.find("delBtn");                
                $A.util.addClass(cmpTarget, 'CursorCustom');
            }else{                
                component.set("v.TOGGLEDELETE",false);
                var cmpTarget = component.find("delBtn");                
                $A.util.removeClass(cmpTarget, 'CursorCustom');
                
            }
        }
        /*
            var getAllId = component.find("Chk");
            if( getAllId != null && getAllId != '' ){
                var count = 0;
                for ( var i = 0; i < getAllId.length; i++ ) {
                    if( component.find( "Chk" )[i].get( "v.value" ) == true ){
                        count = count + 1;
                    }else{
                        component.find("chkAll").set("v.value",false);
                    }
                }
                if( count < 1 ){                
                    component.set("v.TOGGLEDELETE",true);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.addClass(cmpTarget, 'CursorCustom');
                }else{                
                    component.set("v.TOGGLEDELETE",false);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.removeClass(cmpTarget, 'CursorCustom');
                    
                }
            }else{
                    component.set("v.TOGGLEDELETE",false);
                    var cmpTarget = component.find("delBtn");                
                    $A.util.removeClass(cmpTarget, 'CursorCustom');
            }
            */
    },
    selectAllHelper: function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value");        
        var getAllId = component.find("Chk");        
        //var dataListVar = component.get("v.dataList");        
        
        if( component.get("v.dataList").length == 1 ){
            if ( selectedHeaderCheck === true ) {
                if(component.find( "Chk" )[0]){
                    component.find( "Chk" )[0].set( "v.value", true );
                    this.ToggleAdjustHelper(component, event, helper);
                }else{
                    component.find( "Chk" ).set( "v.value", true );
                    this.ToggleAdjustHelper(component, event, helper);
                }
                
            } else {
                if(component.find( "Chk" )[0]){
                    
                    component.find( "Chk" )[0].set("v.value", false);                
                    this.ToggleAdjustHelper(component, event, helper); 
                }else{
                    component.find( "Chk" ).set("v.value", false);                
                    this.ToggleAdjustHelper(component, event, helper);
                }
                
            }
        }
        if( component.get("v.dataList").length > 1 ){
            if ( selectedHeaderCheck === true ) {
                for ( var i = 0; i < getAllId.length; i++ ) {
                    component.find( "Chk" )[i].set( "v.value", true );                
                }
                this.ToggleAdjustHelper(component, event, helper);
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find( "Chk" )[i].set("v.value", false);                
                }
                this.ToggleAdjustHelper(component, event, helper);
            }
        }
        
        
        /*
            if( getAllId != null && getAllId != '' ){
                if ( selectedHeaderCheck === true ) {
                    for ( var i = 0; i < getAllId.length; i++ ) {
                        component.find( "Chk" )[i].set( "v.value", true );                
                    }
                    this.ToggleAdjustHelper(component, event, helper);
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find( "Chk" )[i].set("v.value", false);                
                    }
                    this.ToggleAdjustHelper(component, event, helper);
                }
            }
            */
    },   
    scrl: function(component, event, helper) {  
        this.setTotalPage(component, event, helper);
    },
    scrollRightHelper: function(component, event, helper) { 
        var movement = component.get("v.movement");        
        var x=0;
        var t= setInterval(function(){ x=x+10; 
                                      component.find("scroll").getElement().scrollLeft += 10;
                                      if(x>=movement){
                                          clearInterval(t);
                                      }
                                      
                                     }, 50);
        
        this.setTotalPage(component, event, helper);        
    },
    scrollLeftHelper: function(component, event, helper) {
        var movement = component.get("v.movement");
        var x=0;
        var t= setInterval(function(){ x=x+10; 
                                      component.find("scroll").getElement().scrollLeft -= 10;
                                      if(x>=movement){
                                          clearInterval(t);
                                      }
                                      
                                     }, 50);
        
        this.setTotalPage(component, event, helper);         
    },
    setTotalPage : function(component, event, helper){
        console.log('test');
        if(component.find("scroll") !=undefined && component.find("scroll").getElement()!=null){
            var totalWidth = component.find("scroll").getElement().scrollWidth - component.find("scroll").getElement().clientWidth;
            var totalPage=(Math.round(totalWidth/component.get("v.movement")));
            var currentPage=Math.round(component.find("scroll").getElement().scrollLeft/component.get("v.movement"));
            if(totalPage==0){
                component.set("v.Totalpage",1);
            }else{
                component.set("v.Totalpage",totalPage+1);  
            }                     
            component.set("v.pageNo",currentPage+1);
        }       
    },
    /**************************************** MONTH MODAL METHODS ****************************************/
    openMonthModalHelper: function(component, event, helper) {  
        debugger ;
        component.set("v.toggleModal",true);
        
    },
    closeMonthModalHelper: function(component, event, helper) {    	        
        component.set("v.toggleModal",false);
        this.EnableSubmit(component,event,helper);
        
    }, 
    addMonthBtnClickHelper: function(component, event, helper) {
        debugger ;
        if( event.currentTarget.value != 'DONE' ){
            var previousDateHeader = component.get("v.scheduleHeader");
            var previousTableData = component.get("v.dataList");
            var previousModalData = component.get( "v.MonthData");
            var monthNames = {
                'Jan'  :1, 
                'Feb'  :2, 
                'Mar'  :3, 
                'Apr'  :4, 
                'May'  :5, 
                'Jun'  :6, 
                'Jul'  :7, 
                'Aug'  :8, 
                'Sep'  :9, 
                'Oct'  :10,
                'Nov'  :11,
                'Dec'  :12
            }; 
            var newDateHeader = [];
            newDateHeader.push(
                {
                    label:event.currentTarget.id,
                    /* Removed border: 1px solid rgb(75, 202, 129); from style by Divya */
                    style:'background-color: rgb(75, 202, 129);color:#FFFFFF;font-weight:bold'
                }
            );            
            previousDateHeader = previousDateHeader.concat(newDateHeader);
            //SORTING HEADER
            previousDateHeader = previousDateHeader.sort(function(a, b) {				 
                a = a['label'].split("-");
                b = b['label'].split("-");
                return new Date(a[1], monthNames[a[0]], 1) - new Date(b[1], monthNames[b[0]], 1);                
            });
            //SORTING HEADER
            
            for( var x=0; x < previousTableData.length ; x++ ){
                for( var y=0; y < previousDateHeader.length ; y++ ){
                    if( previousTableData[x].Schedules.length != previousDateHeader.length ){
                        previousTableData[x].Schedules.push(
                            {
                                ScheduleID:'',
                                Quantity:null,
                                productID:previousTableData[x].productID,
                                //schLabel:previousDateHeader[y].label
                                schLabel:event.currentTarget.id                                
                            }
                        );
                    }
                }
            }
            
            //SORTING DATA
            for( var x=0; x < previousTableData.length ; x++ ){
                previousTableData[x].Schedules = previousTableData[x].Schedules.sort(function(a, b) {				 
                    a = a['schLabel'].split("-");
                    b = b['schLabel'].split("-");
                    return new Date(a[1], monthNames[a[0]], 1) - new Date(b[1], monthNames[b[0]], 1);                
                });
            }
            //SORTING DATA
            
            event.currentTarget.className = 'slds-button slds-button_success CursorCustom monthBtn';
            event.currentTarget.value = 'DONE';
            
            //console.log( 'AFTER SORTING::' + JSON.stringify(previousDateHeader) );
            component.set("v.scheduleHeader",previousDateHeader);
            //console.log( 'IN VARIABLE::' + JSON.stringify(component.get("v.scheduleHeader")) );
            console.log( 'AFTER SORTING::' + JSON.stringify(previousTableData) );
            component.set("v.dataList",previousTableData);      
            
            for( var x=0; x < previousModalData.length ; x++ ){
                for( var y=0; y < previousModalData[x].month.length ; y++ ){
                    if( previousModalData[x].month[y].id == event.currentTarget.id )
                        previousModalData[x].month[y].selected = true;
                }
            }
            //console.log( previousModalData );
            component.set( "v.MonthData",previousModalData);
            // Ajay check scroll width
            var self = this;
            setTimeout(function() {
                self.setTotalPage(component, event, helper);}
                       , 1000);
        }
        helper.checkschedules(component,event,helper);
    },
    /**************************************** MONTH MODAL METHODS ****************************************/
    deleteProduct : function(component,event,helper){
        var action = component.get("c.removeSchedule");
        action.setParams({ 
            "SelectedProductid": event.getParam("ProductIds"),
            "recordId":component.get("v.OppId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){ 
                this.prepareTableHelper(component, event ,helper , 'DeleteProd');
            }
        });
        helper.checkschedules(component,event,helper);
        $A.enqueueAction(action);
    },
    RemoveProduct :function(component, event, helper) { 
       if(component.get("v.anySubscrProd") == true && component.get("v.anyNonSubscrProd") == false) 
            component.find("chkAll_Cloud").set("v.value",false);
        else
            component.find("chkAll").set("v.value",false);
        
        var PIdToDelete=[];
        
        var AllChk = component.find("Chk");
        if(component.get("v.dataList").length>1 && !$A.util.isEmpty(AllChk.length)){ 
            for(var i=0;i<AllChk.length;i++){
                var Chk =  AllChk[i].get("v.value");
                if(AllChk[i].get("v.value")){
                    PIdToDelete.push(component.get("v.dataList")[AllChk[i].get("v.text")].productID);                   
                }
            } 
        }
        else if(component.get("v.dataList").length==1 ){  
            if(AllChk[0]){
                var Chk =  AllChk[0].get("v.value");
                if(AllChk[0].get("v.value")){
                    PIdToDelete.push(AllChk[0].get("v.class"));
                }
            }else{
                var Chk =  AllChk.get("v.value");
                if(AllChk.get("v.value")){
                    PIdToDelete.push(AllChk.get("v.class"));
                }
            }
        }
        // this takes care when length >1 but there is only 1 product, i.e. all other are related to package.
            else if($A.util.isEmpty(AllChk.length) ){
                var Chk =  AllChk.get("v.value");
                if(AllChk.get("v.value")){
                    PIdToDelete.push(AllChk.get("v.class"));
                }
            }
        
        if(PIdToDelete.length>0){
            component.set("v.toggleSpinner",true);
            var action = component.get("c.removeOLI");
            action.setParams({ 
                "SelectedProductid": PIdToDelete,
                "recordId":component.get("v.OppId")
            });
            action.setCallback(this, function(a) {
                if(a.getState() === "SUCCESS"){
                    if(!a.getReturnValue()) {
                        component.set("v.toggleSpinner",false);
                        this.RemoveProductHelper(component, event, helper,PIdToDelete);
                        //this.SetDataAfterProductRemove(component,backupList);
                        /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                        FloatMsgEvent.setParams({
                            "Msg" : "Product deleted.",
                            "Category" : "Success",
                            "isShow" : "True" 
                        });
                        FloatMsgEvent.fire();*/
                        //Ajay-jul2021
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": "Product deleted.",
                        "type":"success"
                        });
                        toastEvent.fire();
                    } else {
                         component.set("v.toggleSpinner",false);
                    	 var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": a.getReturnValue(),
                        "type":"error"
                        });
                        toastEvent.fire();    
                    }
                }
                else{                   
                    component.set("v.toggleSpinner",false);
                    console.log('error in delete'+a.getReturnValue());
                  
                }
            });
            $A.enqueueAction(action);
        } 
        
    }
    ,
   /* RemovePackage :function(component, event, helper) { 
        var action = component.get("c.deletePackage");
        action.setParams({ 
            "packageOliId": component.get("v.pkgid"),
            "recordId":component.get("v.recordId")
        });
        component.set("v.toggleSpinner",true);
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){ 
                
                var toastEvent = $A.get("e.force:showToast");
                if(a.getReturnValue().indexOf('ERROR')!=-1){
                    
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Error Occured!!",
                        "message": a.getReturnValue()
                    }); 
                    
                }else{
                    this.RemovePackageHelper(component, event, helper);
                    //this.SetDataAfterProductRemove(component,backupList); 
                    toastEvent.setParams({
                        "type":"success",
                        "title": "Success",
                        "message": a.getReturnValue()
                    }); 
                    
                }
                component.set("v.toggleSpinner",false);
                component.set("v.packageCount", component.get("v.packageCount")-1);
                toastEvent.fire();
            }
            else{
                component.set("v.toggleSpinner",false);
                console.log('error in delete'+a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    RemovePackageHelper: function(component, event, helper){
        var backupList=new Array();
        var subPackage=new Array();
        //backupList =component.get("v.dataList");
        
        var dataObj=component.get("v.dataList");
        var masterpackageId=component.get("v.pkgid");
        // remove package, subpackage, and direct products of main package
        
        for( var x=0; x < dataObj.length ; x++ ){
            // fetches sub package ids to remove relevant Sub package products
            if(dataObj[x].MasterLineId==masterpackageId && dataObj[x].isPackage == true){
                subPackage.push(dataObj[x])  ;
                
            }
            
        }
        var i=0;
        for( var x=0; x < dataObj.length ; x++ ){
            var found=false;
            // Remove main package
            if(dataObj[x].productID==masterpackageId){
                found =true;                
            }
            //found sub package or product of master package
            if(dataObj[x].MasterLineId==masterpackageId){
                found =true;                
            }
            
            if(!found && subPackage.length>0){
                for(var y=0; y < subPackage.length ; y++){
                    if(dataObj[x].MasterLineId==subPackage[y].productID){
                        found =true;  
                        break;
                    }  
                }
            }
            if(!found){
                //dataObj[x].Counter=i;
                backupList.push(dataObj[x]) ;
                // i++;
            }
        }
        this.SetDataAfterProductRemove(component,backupList);
        //component.set("v.dataList",backupList);
        helper.checkschedules(component,event,helper);  
    }, */
    
    RemoveProductHelper: function(component, event, helper, PIdToDelete){
        var backupList=new Array();        
        var dataObj=component.get("v.dataList");      
        for( var x=0; x < dataObj.length ; x++ ){
            var found=false;
            // fetches sub package ids to remove relevant Sub package products
            for(var y=0; y < PIdToDelete.length ; y++){
                if(PIdToDelete[y]==dataObj[x].productID){
                    found=true;               
                }
            }
            if(!found){
                backupList.push(dataObj[x]) ;  
            }
            
        }
        
        this.SetDataAfterProductRemove(component,backupList);
        //component.set("v.dataList",backupList);
        helper.checkschedules(component,event,helper);  
    },
    SetDataAfterProductRemove: function(component,backupList){
        /********************************************************************************************
                    //Static Map for getting month
             ********************************************************************************************/
        var convertingMonth = {
            1: 'Jan',
            2: 'Feb',
            3: 'Mar',
            4: 'Apr',
            5: 'May',
            6: 'Jun',
            7: 'Jul',
            8: 'Aug',
            9: 'Sep',
            10: 'Oct',
            11: 'Nov',
            12: 'Dec'
        };
        var newMapCounterToSchQty=[];
        var newdataList=[];
        var PIdToDelete=[];
        var showCloud = false;
        var showNonCloud = false; 
        //added by Satyam
         var showSubsProd = false;
        var showNonSubsProd = false;
        debugger;
        //Again prepare dalalist array
        for(var i=0;i<backupList.length;i++){
            if(backupList[i].isSubscriptioned == true || backupList[i].RevenueType == 'Cloud') {
                showCloud = true ;
            }
            if(backupList[i].isSubscriptioned == false && backupList[i].RevenueType != 'Cloud')  {
                showNonCloud = true ;
            }
            if(backupList[i].isSubscriptioned == true || component.get("v.subsOnlyRevenueTypes").includes(backupList[i].RevenueType) ||  component.get("v.subsOnlyProdNames").includes(backupList[i].Name) || backupList[i].isCATMProduct == true) {
                          showSubsProd = true;
               }
            if(backupList[i].isSubscriptioned == false && ( !component.get("v.subsOnlyProdNames").includes(backupList[i].Name) && !component.get("v.subsOnlyRevenueTypes").includes(backupList[i].RevenueType) ) &&  backupList[i].isCATMProduct == false) {
                         showNonSubsProd = true;                       
                    }
            newdataList.push(
                {
                    Counter : i,
                    productID:backupList[i].productID,
                    Name:backupList[i].Name,
                    UnitPrice:backupList[i].UnitPrice,
                    //Since this is just re - iterating on same for MOnth/YEAR adjustments Quantity:backupList[i].Quantity for AAS package as well else NumberOfsite
                    Quantity:backupList[i].Quantity,
                    TotalPrice:backupList[i].TotalPrice,
                    RevenueType : backupList[i].RevenueType,
                    //done by sushant
                    TotalACVPrice:backupList[i].TotalACVPrice,
                    TotalTCVPrice:backupList[i].TotalTCVPrice,
                    NumberOfTerms:backupList[i].NumberOfTerms,
                    OneTimeFee:backupList[i].OneTimeFee,
                    MonthlyFee:backupList[i].MonthlyFee,
                     mandateSubscriptioned:component.get("v.subsOnlyProdNames").includes(backupList[i].Name)== true || component.get("v.subsOnlyRevenueTypes").includes(backupList[i].RevenueType)== true?true:false,
                            
                    //done by sushant ends
                    Unscheduled_Quantity:backupList[i].Unscheduled_Quantity,
                    UnchStyleClass : backupList[i].UnchStyleClass,
                    isSubscriptioned :  backupList[i].isSubscriptioned  ,
                    qtyTyp : backupList[i].qtyTyp, //byStuti - EBA -
                    isCATMProduct : backupList[i].isCATMProduct,
                    //Subscription Package 
                    /*isPackage:backupList[i].isPackage,
                    isCompanion:backupList[i].isCompanion,
                    NumberOfLicense:backupList[i].NumberOfLicense,
                    NumberOfSite:backupList[i].NumberOfSite,
                    MasterLineId:backupList[i].MasterLineId,    */                 
                    Schedules:[]
                }
            );
            //List for holding Index and Total Schedule Qty
            newMapCounterToSchQty.push({
                key:i,
                ScheduledQty: backupList[i].Quantity - backupList[i].Unscheduled_Quantity
            });
            for( var j=0; j < backupList[i].Schedules.length ; j++ ){
                if( newdataList[i].productID == backupList[i].Schedules[j].productID ){
                    newdataList[i].Schedules.push(
                        {
                            ScheduleID:backupList[i].Schedules[j].ScheduleID,
                            Quantity:backupList[i].Schedules[j].Quantity,
                            productID:backupList[i].Schedules[j].productID,
                            schLabel:backupList[i].Schedules[j].schLabel
                        }
                    );    
                }
            }   
        } 
        
        component.set("v.anyCloudProduct" , showCloud) ;
        component.set("v.anyNonCloudProduct" , showNonCloud) ;
        
         //added by Satyam
        component.set("v.anySubscrProd",showSubsProd);
        component.set("v.anyNonSubscrProd",showNonSubsProd);
        
        
        component.set("v.dataList",newdataList);
        this.calcTotalTCV(component);
        component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        
        if(component.get("v.dataList").length == 0){
            var scheduleHeader=[];
            component.set("v.scheduleHeader",scheduleHeader);
            var MonthData=[];
            component.set( "v.MonthData",MonthData );
            component.set("v.anyCloudProduct" , false) ;
            component.set("v.anyNonCloudProduct" , false) ;
             component.set("v.anySubscrProd",false);
        	component.set("v.anyNonSubscrProd",false);
        }
    },
 	OnChangeQuantity : function(component,event,helper){
        var counterIndex = component.get("v.Counter") ;
        var ProductUnitPrice= component.find("ProductUnit");
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        var ProductUnschQty = component.find("ProductUnsch");
        var ProductUnschQtyList = component.find("ProductUnsch");
        var ProductQtyList =  component.find("ProductQty") ;
        var ProductTotalList= component.find("ProductTotal");
        var tempProductUnschQty ;
        var tempProductTotal ;
        
        var dataValues = component.get("v.dataList") ;
        debugger;
        
        if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' || component.get("v.isCatm") || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Payments Processing' || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'As a Service')
        {
            //done by sushant starts
            if($A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) || component.get("v.dataList")[counterIndex].NumberOfTerms < 12){
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0);
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0)) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }
                else{
                // EBA_SF-2050 change done by Kapil Bhati           
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0)) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
            else{
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }
                // EBA_SF-2050 change done by Kapil Bhati          
                //  component.get("v.dataList")[component.get("v.Counter")].isCATMProduct==true
                else{        
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
            /*if(component.get("v.dataList")[component.get("v.Counter")].isPackage == true){
                dataValues[counterIndex].Unscheduled_Quantity =  event.getSource().get("v.value")- component.get("v.MapCounterToSchQty")[counterIndex].ScheduledQty/component.get("v.dataList")[counterIndex].NumberOfLicense ;
                
            }
            else{ */
                dataValues[counterIndex].Unscheduled_Quantity =  event.getSource().get("v.value")- component.get("v.MapCounterToSchQty")[counterIndex].ScheduledQty ;
                
           // }
            
        } 
        
        else {
            dataValues[counterIndex].TotalPrice = component.get("v.dataList")[counterIndex].UnitPrice * component.get("v.dataList")[counterIndex].Quantity ;
           	dataValues[counterIndex].TotalACVPrice = dataValues[counterIndex].TotalPrice;
            dataValues[counterIndex].TotalTCVPrice = dataValues[counterIndex].TotalPrice;  
            dataValues[counterIndex].Unscheduled_Quantity =  event.getSource().get("v.value")- component.get("v.MapCounterToSchQty")[counterIndex].ScheduledQty ;
        }
        //done by Sushant Ends
        if(dataValues[counterIndex].Unscheduled_Quantity ==0){
            dataValues[counterIndex].UnchStyleClass = 'unchGreen' ;
        }
        if(dataValues[counterIndex].Unscheduled_Quantity>0){
            dataValues[counterIndex].UnchStyleClass = 'unchYellow' ;
        }
        if(dataValues[counterIndex].Unscheduled_Quantity<0){
            dataValues[counterIndex].UnchStyleClass = 'unchRed' ;
        }
        
        component.set("v.dataList"  , dataValues) ;
        this.calcTotalTCV(component);
        /* for(var i=0;i<ProductUnschQtyList.length;i++){
                if(  ProductUnschQtyList[i].get("v.class").includes(':') &&  ProductUnschQtyList[i].get("v.class").split(':').includes( component.get("v.Counter").toString() )  ) {
                    tempProductUnschQty = ProductUnschQtyList[i];
                    break ;
                }
    
            }
            for(var i=0;i<ProductTotalList.length;i++){
                if(ProductTotalList[i].get("v.labelClass")== component.get("v.Counter")) {
                    tempProductTotal = ProductTotalList[i] ; 
                    break ;
                }
    
            }
            
            if(tempProductUnschQty && tempProductTotal) {
                if(component.get("v.dataList")[counterIndex].RevenueType == 'Cloud') {
                   tempProductTotal.set("v.value",component.get("v.dataList")[counterIndex].UnitPrice * component.get("v.dataList")[counterIndex].Quantity * 12); 
                   tempProductUnschQty.set("v.value",event.getSource().get("v.value") - component.get("v.MapCounterToSchQty")[counterIndex].ScheduledQty);
                } else {
                   tempProductTotal.set("v.value",component.get("v.dataList")[counterIndex].UnitPrice * component.get("v.dataList")[counterIndex].Quantity );  
                   tempProductUnschQty.set("v.value",event.getSource().get("v.value") - component.get("v.MapCounterToSchQty")[counterIndex].ScheduledQty);
                }
                
                var Prdunch=tempProductUnschQty;
                var tempListData = component.get("v.dataList") ;
                
                if(tempProductUnschQty.get("v.value")==0){
                    //Prdunch.set("v.class",'unchGreen'); 
                    tempListData[counterIndex].UnchStyleClass = 'unchGreen' ;
                }
                if(tempProductUnschQty.get("v.value")>0){
                    //Prdunch.set("v.class",'unchYellow');
                    tempListData[counterIndex].UnchStyleClass = 'unchYellow' ;
                }
                if(tempProductUnschQty.get("v.value")<0){
                    //Prdunch.set("v.class",'unchRed');
                    tempListData[counterIndex].UnchStyleClass = 'unchRed' ;
                }
                
                component.set("v.dataList" , tempListData) ;
                
                
            } */
        
        
        
        
        /* if(component.get("v.dataList").length>1){
                for(var i=0;i<ProductUnitPrice.length;i++ ){
                    if(component.get("v.dataList")[i].RevenueType == 'Cloud') {
                        ProductTotal[i].set("v.value",ProductUnitPrice[i].get("v.value") * ProductQty[i].get("v.value") * 12);  
                    }else {
                        ProductTotal[i].set("v.value",ProductUnitPrice[i].get("v.value") * ProductQty[i].get("v.value"));  
                    }
                    if(ProductQty[i].get("v.value") != ProductUnschQty[i].get("v.value") 
                       ){
                        //alert('change of qty'+component.get("v.MapCounterToSchQty")[i].ScheduledQty);
                        if(component.get("v.dataList")[i].RevenueType == 'Cloud') {
                            ProductUnschQty[i].set("v.value",ProductQty[i].get("v.value") - component.get("v.MapCounterToSchQty")[i].ScheduledQty);
                        } else {
                            ProductUnschQty[i].set("v.value",ProductQty[i].get("v.value") - component.get("v.MapCounterToSchQty")[i].ScheduledQty);
                        }
                        //Set Unch Qty color
                        var Prdunch=ProductUnschQty[i];
                        if(ProductUnschQty[i].get("v.value")==0){
                            Prdunch.set("v.class",'unchGreen');
                        }
                        if(ProductUnschQty[i].get("v.value")>0){
                            Prdunch.set("v.class",'unchYellow');
                        }
                        if(ProductUnschQty[i].get("v.value")<0){
                            Prdunch.set("v.class",'unchRed');
                        }
                    } 
                }  
            }
            if(component.get("v.dataList").length==1){
                var Prdunch;
                if(component.find("ProductQty")[0]){
                    Prdunch=ProductUnschQty[0];
                    if(component.get("v.dataList")[0].RevenueType == 'Cloud') {
                        ProductTotal[0].set("v.value",ProductUnitPrice[0].get("v.value") * ProductQty[0].get("v.value") * 12);  
                    }else {
                        ProductTotal[0].set("v.value",ProductUnitPrice[0].get("v.value") * ProductQty[0].get("v.value"));  
    
                    }
                    ProductUnschQty[0].set("v.value",ProductQty[0].get("v.value") - component.get("v.MapCounterToSchQty")[0].ScheduledQty); 
                }else{
                    if(component.get("v.dataList")[0].RevenueType == 'Cloud') {
                        ProductTotal.set("v.value",ProductUnitPrice.get("v.value") * ProductQty.get("v.value") * 12);  
                    }else {
                        ProductTotal.set("v.value",ProductUnitPrice.get("v.value") * ProductQty.get("v.value"));  
    
                    }
                    ProductUnschQty.set("v.value",ProductQty.get("v.value") - component.get("v.MapCounterToSchQty")[0].ScheduledQty);
                    Prdunch=ProductUnschQty;
                }
                
                if(Prdunch.get("v.value")==0){
                    Prdunch.set("v.class",'unchGreen');
                }
                if(Prdunch.get("v.value")>0){
                    Prdunch.set("v.class",'unchYellow');
                }
                if(Prdunch.get("v.value")<0){
                    Prdunch.set("v.class",'unchRed');
                }
            } */
        //if(component.get("v.dataList")[component.get("v.Counter")].isPackage != true){
            //alert('hi:'+component.get("v.dataList")[component.get("v.Counter")].isPackage); 
            this.ValidateTotalPrice(component,event,helper);   
        //}         
        this.EnableSubmit(component,event,helper);
    },
    validateSchQty : function(component,event,helper){                
        var validate = true;
        var schElement = component.find("InputSchQty");  
        if((!$A.util.isUndefinedOrNull(schElement)) && (!$A.util.isArray(schElement))) schElement = [schElement]; 
        var dataListLength = component.get("v.dataList");
        
        if( dataListLength.length > 1 ){
            if(schElement){
                for( var i = 0; i < schElement.length; i++ ){
                    if( schElement[i].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[i].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[i],'customError' );    
                    }else{
                        schElement[i].set("v.errors",null);
                        $A.util.removeClass(schElement[i],'customError');
                    }
                } 
            }
            
        }else{
            if( dataListLength[0].Schedules.length == 1 ){
                if(schElement[0]){
                    if( schElement[0].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[0].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[0],'customError' );    
                    }else{
                        schElement[0].set("v.errors",null);
                        $A.util.removeClass(schElement[0],'customError');
                    }  
                }else{
                    if( schElement.get( "v.value" ) < 0 ){
                        validate = false;
                        schElement.set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement,'customError' );    
                    }else{
                        schElement.set("v.errors",null);
                        $A.util.removeClass(schElement,'customError');
                    } 
                }   
            }else if(dataListLength[0].Schedules.length > 1){
                for( var j = 0; j < schElement.length; j++ ){
                    if( schElement[j].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[j].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[j],'customError' );    
                    }else{
                        schElement[j].set("v.errors",null);
                        $A.util.removeClass(schElement[j],'customError');
                    } 
                }
                
            }
            
        }
        return validate;
    },
    OnChangeSchQty : function(component,event,helper){
        debugger;
        var newMapCounterToSchQty=component.get("v.MapCounterToSchQty");
        var TotalSchQty=0;
        var backupList =component.get("v.dataList");
        var AllSchedulesOfClickedIndex = backupList[component.get("v.Counter")].Schedules;
        
        for(var i=0;i<AllSchedulesOfClickedIndex.length;i++){
            TotalSchQty = TotalSchQty+AllSchedulesOfClickedIndex[i].Quantity;
        }
        
        var ProductUnschQty;
        var NewUnschQty;
        
        for(var i=0;i<component.find("ProductUnsch").length;i++){
            console.log(component.find("ProductUnsch")[i].get("v.value"));
        }
        
        
        var ProductUnschQtyList = component.find("ProductUnsch");
        if((!$A.util.isUndefinedOrNull(ProductUnschQtyList)) && (!$A.util.isArray(ProductUnschQtyList))) ProductUnschQtyList = [ProductUnschQtyList];
        
        var ProductQtyList =  component.find("ProductQty") ;
        if((!$A.util.isUndefinedOrNull(ProductQtyList)) && (!$A.util.isArray(ProductQtyList))) ProductQtyList = [ProductQtyList];
        
        for(var i=0;i<ProductUnschQtyList.length;i++) {
            
            if( (ProductUnschQtyList[i].get("v.class").indexOf(':') != -1) &&  (ProductUnschQtyList[i].get("v.class").split(':').indexOf( component.get("v.Counter").toString() ) != -1) ) {
                ProductUnschQty = ProductUnschQtyList[i];
                break ;
            }
            
        }
        for(var i=0;i<ProductQtyList.length;i++){
            if(ProductQtyList[i].get("v.labelClass")== component.get("v.Counter")) {
                NewUnschQty = ProductQtyList[i].get("v.value") - TotalSchQty; 
                break ;
            }
            
        }
        
        
        
        //alert(component.find("ProductUnsch")[component.get("v.Counter")].get("v.value"));
        //alert(component.find("ProductQty")[component.get("v.Counter")].get("v.value"));
        /* if(component.find("ProductUnsch")[component.get("v.Counter")]){
                ProductUnschQty = component.find("ProductUnsch")[component.get("v.Counter")];
                NewUnschQty = component.find("ProductQty")[component.get("v.Counter")].get("v.value") - TotalSchQty; 
            }
            else{
                ProductUnschQty = component.find("ProductUnsch");
                NewUnschQty = component.find("ProductQty").get("v.value") - TotalSchQty;
            }*/
        
        if(parseInt(NewUnschQty)<0){
            // ProductUnschQty.set("v.class",'unchRed:'+component.get("v.Counter"));
            ProductUnschQty.set("v.value",parseInt(NewUnschQty));
            backupList[component.get("v.Counter")].UnchStyleClass = 'unchRed' ;
        }
        else if(parseInt(NewUnschQty) == 0){
            //ProductUnschQty.set("v.class",'unchGreen:'+component.get("v.Counter"));
            ProductUnschQty.set("v.value",parseInt(NewUnschQty));
            backupList[component.get("v.Counter")].UnchStyleClass = 'unchGreen' ;
            
        }
            else{
                //ProductUnschQty.set("v.class",'unchYellow:'+component.get("v.Counter"));
                ProductUnschQty.set("v.value",parseInt(NewUnschQty));
                backupList[component.get("v.Counter")].UnchStyleClass = 'unchYellow' ;
            } 
        component.set("v.dataList" , backupList) ;
        var  tempMapCounterToSchQty =[];
        /*if(backupList[component.get("v.Counter")].isPackage){
            tempMapCounterToSchQty.push({
                key:component.get("v.Counter"),
                ScheduledQty : parseInt(TotalSchQty)*backupList[component.get("v.Counter")].NumberOfLicense
            });
        } */
        //else{
            tempMapCounterToSchQty.push({
                key:component.get("v.Counter"),
                ScheduledQty : parseInt(TotalSchQty)
            });
       // }
        tempMapCounterToSchQty.push({
            key:component.get("v.Counter"),
            ScheduledQty : parseInt(TotalSchQty)
        });
        newMapCounterToSchQty.splice(component.get("v.Counter"),1,tempMapCounterToSchQty[0]);
        this.EnableSubmit(component,event,helper);
        
        component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        console.log(component.get("v.MapCounterToSchQty"));
        
    },
    deleteMonthBtnClickHelper: function(component, event, helper) {
        debugger ;
        var clickedBtnID = event.currentTarget.id;
        console.log('clickedBtnID'+clickedBtnID);
        var previousDateHeader = component.get("v.scheduleHeader");
        var previousTableData = component.get("v.dataList");
        var previousModalData = component.get( "v.MonthData");
        var previousMapCounterToSchQty = component.get( "v.MapCounterToSchQty");
        
        for( var i = 0; i < previousDateHeader.length; i++ ) {
            if( previousDateHeader[i].label == clickedBtnID ) {
                previousDateHeader.splice(i, 1);
                break;
            }
        }
        component.set( "v.scheduleHeader",previousDateHeader );
        
        for( var y=0; y < previousTableData.length ; y++ ){
            for( var z=0; z < previousTableData[y].Schedules.length; z++ ){
                console.log(JSON.stringify(previousTableData[y].Schedules[z]));
                console.log('Schedule month'+previousTableData[y].Schedules[z].schLabel);
                if( previousTableData[y].Schedules[z].schLabel == clickedBtnID ){
                    console.log('inside condition match');
                    var minusQty;
                    if( previousTableData[y].Schedules[z].Quantity == null ){
                        minusQty = 0;
                    }else{
                        minusQty = previousTableData[y].Schedules[z].Quantity;
                    }
                    previousMapCounterToSchQty[y].ScheduledQty = previousMapCounterToSchQty[y].ScheduledQty - minusQty;
                    previousTableData[y].Schedules.splice(z, 1);
                    if(previousTableData[y].Quantity != null  ) {
                        previousTableData[y].Unscheduled_Quantity  = previousTableData[y].Quantity - previousMapCounterToSchQty[y].ScheduledQty ;
                    }
                    
                } 
            }   
        }        
        component.set( "v.MapCounterToSchQty",previousMapCounterToSchQty);
        component.set( "v.dataList",previousTableData );
        //console.log('yegjahati'+JSON.stringify(component.get( "v.MapCounterToSchQty")));
        for( var a=0; a < previousModalData.length ; a++ ){
            for( var b=0; b < previousModalData[a].month.length; b++ ){
                if( previousModalData[a].month[b].id == clickedBtnID ){
                    previousModalData[a].month[b].selected = false;
                }
            }
        }
        component.set( "v.MonthData",previousModalData );
        this.OnRemoveSchMonth(component,event,helper);
        // Ajay set total Page
        var self = this;
        (function() {
            self.setTotalPage(component, event, helper);}
         , 1000);
        helper.checkschedules(component,event,helper);
    },
    addMoreYearHelper : function(component,event,helper){
        var CalenderCount = component.get( "v.calenderCount" ) + 1;
        var EDD = component.get( "v.EBD" );
        var today = new Date();
        var yearObj = [];
        //var EDDMonth = EDD.getMonth() + 1;
        var EDDMonth = new Date(EDD).getMonth() + 1;
        var EDDYear = new Date(EDD).getFullYear();
        var convertingMonth = {
            1: 'Jan',
            2: 'Feb',
            3: 'Mar',
            4: 'Apr',
            5: 'May',
            6: 'Jun',
            7: 'Jul',
            8: 'Aug',
            9: 'Sep',
            10: 'Oct',
            11: 'Nov',
            12: 'Dec'
        };
        var alreadySelected = component.get( "v.scheduleHeader" );                  
        var tempArr = [];
        for( var i=0; i < alreadySelected.length ; i++ ){
            tempArr.push( alreadySelected[i].label );
        }
        
        
        for( var i=0; i < CalenderCount; i++ ){ 
            
            yearObj.push(
                {
                    year:EDDYear + i,
                    month:[]
                }
            );
            for ( var key in convertingMonth ) {
                yearObj[i].month.push(
                    { 
                        label:convertingMonth[key],
                        id:convertingMonth[key]+'-'+(EDDYear + i),
                        disable:( EDDMonth > key && EDDYear + i == EDDYear ? true : false),
                        selected:tempArr.includes( convertingMonth[key]+'-'+(EDDYear + i) ),
                        access : EDDMonth > key && EDDYear + i == EDDYear ? 'Not Available' : tempArr.includes( convertingMonth[key]+'-'+(today.getFullYear() + i) ) ? 'Selected' : 'Select'
                        
                    }
                );
            }            
        }
        component.set( "v.MonthData",yearObj );
        component.set( "v.calenderCount",CalenderCount );
    },
    //Zero allowed
    ValidateDataGeneric : function(component,event,helper,auraid,type){
        var Validated=true;
        
        if(component.find(auraid).length>1){
            for(var c in component.find(auraid)){
                if($A.util.isEmpty(component.find(auraid)[c].get("v.value")) || $A.util.isUndefined(component.find(auraid)[c].get("v.value"))|| component.find(auraid)[c].get("v.value") < 0 ){
                    component.find(auraid)[c].set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid)[c],'customError');
                    Validated=false;
                }else{
                    component.find(auraid)[c].set("v.errors",null);
                    $A.util.removeClass(component.find(auraid)[c],'customError'); 
                }
            }  
        }else{
            try{
                if( $A.util.isUndefined(component.find(auraid).get("v.value"))||$A.util.isEmpty(component.find(auraid).get("v.value")) || $A.util.isUndefined(component.find(auraid).get("v.value"))|| component.find(auraid).get("v.value") < 0 ){
                    component.find(auraid).set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid),'customError');
                    Validated=false;
                }else{
                    component.find(auraid).set("v.errors",null);
                    $A.util.removeClass(component.find(auraid),'customError'); 
                }
            }catch(err) {
                if( $A.util.isUndefined(component.find(auraid)[0].get("v.value"))||$A.util.isEmpty(component.find(auraid)[0].get("v.value")) || component.find(auraid)[0].get("v.value") < 0 ){
                    component.find(auraid)[0].set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid)[0],'customError');
                    Validated=false;
                }else{
                    component.find(auraid)[0].set("v.errors",null);
                    $A.util.removeClass(component.find(auraid)[0],'customError'); 
                }
            }
        }
        
        component.set("v.haserror",Validated);
        return Validated;
    },
    //Zero not allowed
    ValidateDataGenericPositive : function(component,event,helper,auraid,type){
        var Validated=true;
        if(component.find(auraid).length>1){
            for(var c in component.find(auraid)){
                if($A.util.isEmpty(component.find(auraid)[c].get("v.value")) || $A.util.isUndefined(component.find(auraid)[c].get("v.value")) || component.find(auraid)[c].get("v.value") <= 0){
                    component.find(auraid)[c].set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid)[c],'customError'); 
                    Validated=false;
                }else{
                    component.find(auraid)[c].set("v.errors",null);
                    $A.util.removeClass(component.find(auraid)[c],'customError'); 
                }
                
            } 
        }else{
            
            try{
                if( $A.util.isEmpty(component.find(auraid).get("v.value")) || $A.util.isUndefined(component.find(auraid).get("v.value")) || component.find(auraid).get("v.value") <= 0 ){
                    component.find(auraid).set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid),'customError');
                    Validated=false;
                }else{
                    component.find(auraid).set("v.errors",null);
                    $A.util.removeClass(component.find(auraid),'customError'); 
                }
            }catch(err) {
                if( $A.util.isEmpty(component.find(auraid)[0].get("v.value")) || $A.util.isUndefined(component.find(auraid)[0].get("v.value")) || component.find(auraid)[0].get("v.value") <= 0 ){
                    component.find(auraid)[0].set("v.errors", [{message:"Invalid Quantity"}]);
                    $A.util.addClass(component.find(auraid)[0],'customError');
                    Validated=false;
                }else{
                    component.find(auraid)[0].set("v.errors",null);
                    $A.util.removeClass(component.find(auraid)[0],'customError'); 
                }
            }
        }  
        
        
        
        component.set("v.haserror",Validated);            
        return Validated;
    },
    
    ValidateData : function(component,event,helper){
        var Validated=true;
        var index= component.get("v.Counter");
        
        console.log('index'+index);
        var ProductQty;
        if(component.get("v.dataList").length>1){
            ProductQty  = component.find("ProductQty")[index]; 
        }  
        else if(component.get("v.dataList").length == 1){
            if(component.find("ProductQty")[0]){
                ProductQty  = component.find("ProductQty")[0]; 
            }
            else{
                ProductQty  = component.find("ProductQty") 
            }
        }   
        
        if($A.util.isEmpty(ProductQty.get("v.value")) || $A.util.isUndefined(ProductQty.get("v.value")) || ProductQty.get("v.value") <= 0 ){
            ProductQty.set("v.errors", [{message:"Invalid Quantity"}]);
            $A.util.addClass(ProductQty,'customError');
            Validated = false;
        }         
        else {
            ProductQty.set("v.errors",null);
            $A.util.removeClass(ProductQty,'customError');
        }
        return Validated;
    },
    ValidateUnitPrice : function(component,event,helper){
        console.log('inside validate unit price');
        var Validated=true;
        var index= component.get("v.Counter");
        console.log('counter val'+index);
        var ProductUnitPrice;
        if(component.get("v.dataList").length>1)
            ProductUnitPrice = event.getSource();
        //ProductUnitPrice = component.find("ProductUnit")[index];
        else if(component.get("v.dataList").length == 1){
            if(component.find("ProductUnit")[0]){
                ProductUnitPrice = component.find("ProductUnit")[0];
            }else{
                ProductUnitPrice = component.find("ProductUnit");
            }
        }
        if($A.util.isEmpty(ProductUnitPrice.get("v.value")) || $A.util.isUndefined(ProductUnitPrice.get("v.value")) || ProductUnitPrice.get("v.value") < 0 ){
            ProductUnitPrice.set("v.errors", [{message:"Invalid Price"}]);
            $A.util.addClass(ProductUnitPrice,'customError');
            Validated = false;
        }         
        else {
            ProductUnitPrice.set("v.errors",null);
            $A.util.removeClass(ProductUnitPrice,'customError');
        }
        return Validated;
    },
    
    ///////////////////////////Done By Sushant/////////////////////////////////////
    ValidateNumberOfTerms : function(component,event,helper){ 
        console.log('inside validate Number Of Terms');
        var Validated=true;
        /*var index= component.get("v.Counter");
            
            var NOT;
            if(component.get("v.dataList").length>1){
                NOT  = component.find("NumberOfTerms")[index]; 
            }  
            else if(component.get("v.dataList").length == 1){
                if(component.find("NumberOfTerms")[0]){
                    NOT  = component.find("NumberOfTerms")[0]; 
                }
                else{
                    NOT  = component.find("NumberOfTerms") 
                }
            }   
            if($A.util.isEmpty(NOT.get("v.value")) || $A.util.isUndefined(NOT.get("v.value")) || NOT.get("v.value") <= 0 ){
                NOT.set("v.errors", [{message:"Invalid Quantity"}]);
                $A.util.addClass(NOT,'customError');
                Validated = false;
            }         
            else {
                NOT.set("v.errors",null);
                $A.util.removeClass(NOT,'customError');
            }*/
        return Validated;
    }
    ,
    
    ///////////////////////////Done By Sushant/////////////////////////////////////
    ValidateOTF : function(component,event,helper){ 
        debugger;
        console.log('inside validate Number Of Terms');
        var Validated=true;
        /*    var index= component.get("v.Counter");
            
            var OTF;
            
            var tempList = component.get("v.dataList") ;
            OTF = tempList[index].OneTimeFee  ;
           if(component.get("v.dataList").length>1){
                OTF  = component.find("OneTimeFee")[index]; 
            }  
            else if(component.get("v.dataList").length == 1){
                if(component.find("OneTimeFee")[0]){
                    OTF  = component.find("OneTimeFee")[0]; 
                }
                else{
                    OTF  = component.find("OneTimeFee") 
                }
            }   
                    alert('@@@'+OTF);
    
            if($A.util.isEmpty(OTF.get("v.value")) || $A.util.isUndefined(OTF.get("v.value")) || OTF.get("v.value") <= 0 ){
                NOT.set("v.errors", [{message:"Invalid Quantity"}]);
                $A.util.addClass(OTF,'customError');
                Validated = false;
            }         
            else {
                NOT.set("v.errors",null);
                $A.util.removeClass(OTF,'customError');
            }*/

    },
    ///////////////////////Done by Sushant ends////////////////////////////////////////
    OnChangeUnitPrice : function(component,event,helper){ 
        var counterIndex = component.get("v.Counter") ; 
        var ProductUnitPrice= component.find("ProductUnit"); 
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        console.log('inside onchange unit price'+component.get("v.dataList").length);
        console.log('datalist value'+ JSON.stringify(component.get("v.dataList")));
        //var ProductUnschQtyList = component.find("ProductUnsch");
        var ProductTotalList =  component.find("ProductTotal") ;
        var tempProductTotal;
        var dataValues = component.get("v.dataList") ;
        
        if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' ||
           component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'As a Service' || component.get("v.isCatm") || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Payments Processing'){
           
            //done by sushant starts
            if($A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) || component.get("v.dataList")[counterIndex].NumberOfTerms < 12){
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0) ;
            if(component.get("v.isCatm")){
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0)) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee ); 
            } 
                //EBA_SF-2050 change done by Kapil Bhati               
            else{
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0)) +(component.get("v.dataList")[counterIndex].OneTimeFee );
            }
            }
            else{
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
            if(component.get("v.isCatm")){
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
            }
            else{
            //EBA_SF-2050 change done by Kapil Bhati               
            dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
              }
                  
		  if(component.get("v.isCatm"))
                dataValues[counterIndex].MonthlyFee = parseFloat(component.get("v.dataList")[counterIndex].MonthlyFee).toFixed(4);
                else
                    dataValues[counterIndex].MonthlyFee = parseFloat(component.get("v.dataList")[counterIndex].MonthlyFee).toFixed(2);
            }
            
        }
        //done by sushant ends
        else {
            dataValues[counterIndex].TotalPrice = component.get("v.dataList")[component.get("v.Counter")].UnitPrice * component.get("v.dataList")[component.get("v.Counter")].Quantity  ;
            dataValues[counterIndex].TotalACVPrice = dataValues[counterIndex].TotalPrice;
            dataValues[counterIndex].TotalTCVPrice = dataValues[counterIndex].TotalPrice;
            //[counterIndex].qtyTyp = component.get("v.dataList")[counterIndex].qtyTyp;

        }
        component.set("v.dataList" ,dataValues ) ;
        this.calcTotalTCV(component);
        /* for(var i=0;i<ProductTotalList.length;i++){
                if( ProductTotalList[i].get("v.labelClass") ==  component.get("v.Counter") ) {
                    tempProductTotal = ProductTotalList[i];
                    break ;
                }
    
            }
           
            if(component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' ) {
                tempProductTotal.set("v.value",component.get("v.dataList")[component.get("v.Counter")].UnitPrice * component.get("v.dataList")[component.get("v.Counter")].Quantity * 12);  
            }else {
                tempProductTotal.set("v.value",component.get("v.dataList")[component.get("v.Counter")].UnitPrice * component.get("v.dataList")[component.get("v.Counter")].Quantity  );  
            } */
        this.EnableSubmit(component,event,helper);
        
        /* if(component.get("v.dataList").length>1){
                console.log('inside length greater 1');
                for(var i=0;i<ProductUnitPrice.length;i++ ){ 
                    console.log('inside for loop');
                    if(component.get("v.dataList")[i].RevenueType == 'Cloud' ) {
                        ProductTotal[i].set("v.value",ProductUnitPrice[i].get("v.value") * ProductQty[i].get("v.value") * 12);  
                    }else {
                        ProductTotal[i].set("v.value",ProductUnitPrice[i].get("v.value") * ProductQty[i].get("v.value"));  
                    }
                    console.log('inside for loop'+ProductTotal[i].get("v.value"));
                }  
                this.EnableSubmit(component,event,helper);
            }
            if(component.get("v.dataList").length==1){
                if(component.find("ProductUnit")[0]){
                    if(component.get("v.dataList")[0].RevenueType == 'Cloud' ) {
                        ProductTotal[0].set("v.value",ProductUnitPrice[0].get("v.value") * ProductQty[0].get("v.value") * 12);
                    }else {
                        ProductTotal[0].set("v.value",ProductUnitPrice[0].get("v.value") * ProductQty[0].get("v.value"));
                    }
                    
                }
                else{
                    
                     if(component.get("v.dataList")[0].RevenueType == 'Cloud' ) {
                         ProductTotal.set("v.value",ProductUnitPrice.get("v.value") * ProductQty.get("v.value") * 12);
                    }else {
                         ProductTotal.set("v.value",ProductUnitPrice.get("v.value") * ProductQty.get("v.value"));
                    }
                }  
                this.EnableSubmit(component,event,helper);
            }  */
    },
    /////////////////////////////////Done by Sushant//////////////////////////////////////////////////////////
    OnChangeNumberOfTermsPkg : function(component,event,helper){
        var masterpackageId=component.get("v.dataList")[component.get("v.Counter")].productID;
        var dataObj=component.get("v.dataList");
        
        for( var x=0; x < dataObj.length ; x++ ){          
            //found sub package or product of master package
            if(dataObj[x].MasterLineId==masterpackageId||dataObj[x].productID==masterpackageId){
                dataObj[x].NumberOfTerms =component.get("v.dataList")[component.get("v.Counter")].NumberOfTerms;
                this.calculateACV_TCV(component,event,helper,dataObj[x]);
            }         
            
        }
        component.set("v.dataList",dataObj);
        this.EnableSubmit(component,event,helper);
        
        //this.OnChangeNumberOfTerms(component,event,helper);
    },
           calculateACV_TCV : function(component,event,helper,dataObj){
            
            if(dataObj.NumberOfTerms < 12){
                dataObj.TotalACVPrice = dataObj.MonthlyFee * dataObj.Quantity * dataObj.NumberOfTerms ;
                if(component.get("v.isCatm")){
                    dataObj.TotalTCVPrice = (dataObj.MonthlyFee * dataObj.Quantity * dataObj.NumberOfTerms) +(dataObj.Quantity * dataObj.OneTimeFee );
                }
                else{
                    //EBA_SF-2050 change done by Kapil Bhati     
                    dataObj.TotalTCVPrice = (dataObj.MonthlyFee * dataObj.Quantity * dataObj.NumberOfTerms) +(dataObj.OneTimeFee );
                }
            }
            else{
                dataObj.TotalACVPrice = dataObj.MonthlyFee * dataObj.Quantity * 12 ;
                if(component.get("v.isCatm")){
                    dataObj.TotalTCVPrice = (dataObj.MonthlyFee * dataObj.Quantity * dataObj.NumberOfTerms) +(dataObj.Quantity * dataObj.OneTimeFee );
                }
                else{
                    //EBA_SF-2050 change done by Kapil Bhati      
                    dataObj.TotalTCVPrice = (dataObj.MonthlyFee * dataObj.Quantity * dataObj.NumberOfTerms) +(dataObj.OneTimeFee );
                }
            }
            
            // component.set("v.dataList" ,dataValues ) ;
        },
    
	    OnChangeNumberOfTerms : function(component,event,helper){
                var counterIndex = component.get("v.Counter") ; 
                var ProductUnitPrice= component.find("ProductUnit");
                var ProductTotal= component.find("ProductTotal");
                var ProductQty= component.find("ProductQty");
                console.log('inside onchange unit price'+component.get("v.dataList").length);
                
                //var ProductUnschQtyList = component.find("ProductUnsch");
                var ProductTotalList =  component.find("ProductTotal") ;
                var tempProductTotal ;
                var dataValues = component.get("v.dataList") ;
                
                if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' || component.get("v.isCatm") || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Payments Processing' || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'As a Service'
                  ) {
                    if(component.get("v.dataList")[counterIndex].NumberOfTerms < 12){
                        dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms ;
                        if(component.get("v.isCatm")){
                            dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                        }
                        else{
                            //EBA_SF-2050 change done by Kapil Bhati               
                            dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                        }
                    }
                    else{
                        dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
                        if(component.get("v.isCatm")){
                            dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                        }else{
                            //EBA_SF-2050 change done by Kapil Bhati          
                            dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                        }
                    }
                }else {
                    dataValues[counterIndex].TotalPrice = component.get("v.dataList")[component.get("v.Counter")].UnitPrice * component.get("v.dataList")[component.get("v.Counter")].Quantity  ;
                }
                component.set("v.dataList" ,dataValues ) ;
                this.calcTotalTCV(component);
                this.EnableSubmit(component,event,helper);
            },
                
        OnOppMonthChange : function(component,event,helper) {
            
            var ProductUnitPrice= component.find("ProductUnit");
            var ProductTotal= component.find("ProductTotal");
            var ProductQty= component.find("ProductQty");
            var oppMonths = component.get("v.oppMonths");
            console.log('inside onchange unit price'+component.get("v.dataList").length);
            
            //var ProductUnschQtyList = component.find("ProductUnsch");
            var ProductTotalList =  component.find("ProductTotal") ;
            var tempProductTotal ;
            var dataValues = component.get("v.dataList") ;
            
            dataValues.forEach((item, index) => {
                var counterIndex = index; 
                component.get("v.dataList")[counterIndex].NumberOfTerms = oppMonths;
                
                if(component.get("v.dataList")[index].isSubscriptioned == true || component.get("v.dataList")[index].RevenueType == 'Cloud' || component.get("v.isCatm") || component.get("v.dataList")[index].RevenueType == 'Payments Processing' || component.get("v.dataList")[index].RevenueType == 'As a Service') {
                if(oppMonths < 12){
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * oppMonths ;
                if(component.get("v.isCatm")){        
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
            }else{ 
                   //EBA_SF-2050 change done by Kapil Bhati               
                   dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * oppMonths) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
             else{
             dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
            if(component.get("v.isCatm")){
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
            }else{
                //EBA_SF-2050 change done by Kapil Bhati          
                dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * oppMonths) +(component.get("v.dataList")[counterIndex].OneTimeFee );
            }
            }
            }else {
                dataValues[counterIndex].TotalPrice = component.get("v.dataList")[counterIndex].UnitPrice * component.get("v.dataList")[counterIndex].Quantity  ;
                dataValues[counterIndex].TotalACVPrice = dataValues[counterIndex].TotalPrice;
                dataValues[counterIndex].TotalTCVPrice = dataValues[counterIndex].TotalPrice;  
            }   
            });
            
            component.set("v.dataList" ,dataValues ) ;
            this.EnableSubmit(component,event,helper);
    },
     OnChangeOTF: function(component,event,helper){
        var counterIndex = component.get("v.Counter") ; 
        var ProductUnitPrice= component.find("ProductUnit");
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        console.log('inside onchange unit price'+component.get("v.dataList").length);
        
        //var ProductUnschQtyList = component.find("ProductUnsch");
        var ProductTotalList =  component.find("ProductTotal") ;
        var tempProductTotal ;
        var dataValues = component.get("v.dataList") ;
        if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' ||
            component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'As a Service' || component.get("v.isCatm")
          ) {
            if($A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) || component.get("v.dataList")[counterIndex].NumberOfTerms < 12){
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0) ;
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0) ) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }else{
                    //EBA_SF-2050 change done by Kapil Bhati
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * (!$A.util.isEmpty(component.get("v.dataList")[counterIndex].NumberOfTerms) ? component.get("v.dataList")[counterIndex].NumberOfTerms : 0) ) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
            else{
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }
                else{//EBA_SF-2050 change done by Kapil Bhati          
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
        }else {
            dataValues[counterIndex].TotalPrice = component.get("v.dataList")[component.get("v.Counter")].UnitPrice * component.get("v.dataList")[component.get("v.Counter")].Quantity  ;
        }
        component.set("v.dataList" ,dataValues) ;
        this.calcTotalTCV(component);
        this.EnableSubmit(component,event,helper);
    },
    //////////////////////////Done by Sushant///////////////////
    ValidateTotalPrice :  function(component,event,helper){
        //alert(JSON.stringify(component.get("v.dataList")));
        var Validated=true;
        var index= component.get("v.Counter");
        //alert('index: '+index);
        var ProductTotalPrice;
        if(component.get("v.dataList").length>1)
        { 
            //alert('index1: '+index);
            //ProductTotalPrice = component.find("ProductTotal")[index];
            ProductTotalPrice = event.getSource();
            // alert(component.find("ProductTotal"));
            //alert('ProductTotal: '+JSON.stringify(ProductTotalPrice)); 
        }
        else if(component.get("v.dataList").length == 1) {
            if(component.find("ProductTotal")[0]){
                ProductTotalPrice = component.find("ProductTotal")[0]; 
            }else{
                ProductTotalPrice = component.find("ProductTotal"); 
            }
        }
        if($A.util.isEmpty(ProductTotalPrice.get("v.value")) || $A.util.isUndefined(ProductTotalPrice.get("v.value")) || ProductTotalPrice.get("v.value") < 0){
            ProductTotalPrice.set("v.errors", [{message:"Invalid Price"}]);
            $A.util.addClass(ProductTotalPrice,'customError');
            Validated = false;
        }         
        else {
            ProductTotalPrice.set("v.errors",null);
            $A.util.removeClass(ProductTotalPrice,'customError');
        }
        return Validated;
    },
    ValidateSchQty : function(component,event,helper){
        console.log('ValidateSchQty');
        var validate = true;
        var schElement = component.find("InputSchQty");                
        var dataListLength = component.get("v.dataList");
        
        if((!$A.util.isUndefinedOrNull(schElement)) && (!$A.util.isArray(schElement))) schElement = [schElement];
        
        if( dataListLength.length > 1 ){  
            if( schElement ){
                for( var i = 0; i < schElement.length; i++ ){
                    if( schElement[i].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[i].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[i],'customError' );    
                    }else{
                        schElement[i].set("v.errors",null);
                        $A.util.removeClass(schElement[i],'customError');
                    }
                }   
            }
        }else{
            if( dataListLength[0].Schedules.length == 1 ){
                console.log('inside one sch ');
                
                if(schElement[0]){
                    console.log('inside one sch if');
                    if( schElement[0].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[0].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[0],'customError' );    
                    }else{
                        schElement[0].set("v.errors",null);
                        $A.util.removeClass(schElement[0],'customError');
                    }
                }else{
                    console.log('inside one sch else');
                    if( schElement.get( "v.value" ) < 0 ){
                        validate = false;
                        schElement.set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement,'customError' );    
                    }else{
                        schElement.set("v.errors",null);
                        $A.util.removeClass(schElement,'customError');
                    }
                }
                
            }else{
                for( var j = 0; j < schElement.length; j++ ){
                    if( schElement[j].get( "v.value" ) < 0 ){
                        validate = false;
                        schElement[j].set("v.errors", [{message:"Invalid value"}]);
                        $A.util.addClass( schElement[j],'customError' );    
                    }else{
                        schElement[j].set("v.errors",null);
                        $A.util.removeClass(schElement[j],'customError');
                    }
                }
            }
            
        }
        return validate;        
    },
    OnChangeTotalVal : function(component,event,helper) {
        var counterIndex = component.get("v.Counter") ;
        var ProductUnitPrice= component.find("ProductUnit");
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        
        var ProductUnitPriceList =  component.find("ProductUnit") ;
        var tempProductUnit ;
        var dataValues = component.get("v.dataList") ;
        
        if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || 
           component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' || component.get("v.isCatm") || component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Payments Processing') {
            
            //done by sushant
            if(component.get("v.dataList")[counterIndex].NumberOfTerms < 12){
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms ;
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }
                else{
                    // EBA_SF-2050 change done by Kapil Bhati           
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }}
            else{
                dataValues[counterIndex].TotalACVPrice = component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * 12 ;
                if(component.get("v.isCatm")){
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].OneTimeFee );
                }else{
                    // EBA_SF-2050 change done by Kapil Bhati            
                    dataValues[counterIndex].TotalTCVPrice = (component.get("v.dataList")[counterIndex].MonthlyFee * component.get("v.dataList")[counterIndex].Quantity * component.get("v.dataList")[counterIndex].NumberOfTerms) +(component.get("v.dataList")[counterIndex].OneTimeFee );
                }
            }
        }
        //done by sushant
        else {
            dataValues[counterIndex].UnitPrice = component.get("v.dataList")[component.get("v.Counter")].TotalPrice /  component.get("v.dataList")[component.get("v.Counter")].Quantity  ;
        }
        
        component.set("v.dataList" , dataValues) ;
        
        
        /* for(var i=0;i<ProductUnitPriceList.length;i++){
                if( ProductUnitPriceList[i].get("v.labelClass") ==  component.get("v.Counter") ) {
                    tempProductUnit = ProductUnitPriceList[i];
                    break ;
                }
    
            }
            
            if(tempProductUnit) {
                
                if(component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud' ) {
                    tempProductUnit.set("v.value",  component.get("v.dataList")[component.get("v.Counter")].TotalPrice / ( component.get("v.dataList")[component.get("v.Counter")].Quantity * 12) ) ;  
                }else {
                    tempProductUnit.set("v.value",  component.get("v.dataList")[component.get("v.Counter")].TotalPrice / component.get("v.dataList")[component.get("v.Counter")].Quantity );  
                }
                
            } */
        
        
        /*if(component.get("v.dataList").length>1){  
                for(var i=0;i<ProductUnitPrice.length;i++ ){   
                    if(ProductQty[i].get("v.value")) {
                         if(component.get("v.dataList")[i].RevenueType == 'Cloud' ) {
                             ProductUnitPrice[i].set("v.value",  ProductTotal[i].get("v.value") / ( ProductQty[i].get("v.value") * 12) ) ;  
                         }else {
                             ProductUnitPrice[i].set("v.value",  ProductTotal[i].get("v.value") / ProductQty[i].get("v.value") );  
                         }
                    }
                }   
            }
            if(component.get("v.dataList").length==1){
                if(component.find("ProductQty")[0]) {
                    if(component.get("v.dataList")[0].RevenueType == 'Cloud' ) {
                         ProductUnitPrice[0].set("v.value",ProductTotal[0].get("v.value") / ( ProductQty[0].get("v.value") * 12 ) );  
                    } else {
                         ProductUnitPrice[0].set("v.value",ProductTotal[0].get("v.value") / ProductQty[0].get("v.value") );  
                    }
                }
                else {
                    if(component.get("v.dataList")[0].RevenueType == 'Cloud' ) {
                        ProductUnitPrice.set("v.value",ProductTotal.get("v.value") / ( ProductQty.get("v.value") * 12) ); 
                    } else {
                        ProductUnitPrice.set("v.value",ProductTotal.get("v.value") / ProductQty.get("v.value") ); 
                    }
                    
                }
            }  */
        this.ValidateUnitPrice(component,event,helper);
        this.EnableSubmit(component,event,helper);
    },
                    
    Submit  : function(component,event,helper){
        if(this.ValidationBeforeSubmit(component,event,helper) && 
           this.validateSchQty(component,event,helper) //&&
           //this.ValidateInputs(component,event,helper)
          ){
            this.WarningSchBeforeSubmit(component,event,helper);
            this.CreateJason(component,event,helper);  
            this.DisableSubmit(component,event,helper);
        }
    }, 
    OnRemoveSchMonth : function(component,event,helper){
        var ProductQty= component.find("ProductQty");
        var ProductUnschQty = component.find("ProductUnsch");
        var newDataList = component.get("v.dataList") ;
        debugger ;        
        for(var l=0; l<newDataList.length; l++) {
            if(newDataList[l].Unscheduled_Quantity ) {
                if(newDataList[l].Unscheduled_Quantity ==0){
                    newDataList[l].UnchStyleClass =  'unchGreen' ;
                }
                else if(newDataList[l].Unscheduled_Quantity >0){
                    newDataList[l].UnchStyleClass =  'unchYellow' ; 
                }
                    else if(newDataList[l].Unscheduled_Quantity <0){
                        newDataList[l].UnchStyleClass =  'unchRed';
                    }
                
            }
        }
        component.set("v.dataList" ,  newDataList) ; 
        
        /*  if(component.get("v.dataList").length>1){
                for(var i=0;i<ProductQty.length;i++ ){   
                    if(ProductQty[i].get("v.value") != ProductUnschQty[i].get("v.value")) 
                    {
                        //alert('sch qty'+component.get("v.MapCounterToSchQty")[i].ScheduledQty);
                        //alert('uschsch qty'+parseInt(ProductQty[i].get("v.value")) - parseInt(component.get("v.MapCounterToSchQty")[i].ScheduledQty));
                        ProductUnschQty[i].set("v.value",ProductQty[i].get("v.value") - component.get("v.MapCounterToSchQty")[i].ScheduledQty);
                        //Set Unch Qty color
                        var Prdunch=ProductUnschQty[i];
                        if(ProductUnschQty[i].get("v.value")==0){
                            Prdunch.set("v.class",'unchGreen');
                        }
                        if(ProductUnschQty[i].get("v.value")>0){
                            Prdunch.set("v.class",'unchYellow');
                        }
                        if(ProductUnschQty[i].get("v.value")<0){
                            Prdunch.set("v.class",'unchRed');
                        }
                    } 
                }  
            }
            
            if(component.get("v.dataList").length==1){
                var Prdunch;
                if(component.find("ProductQty")[0]){
                    ProductUnschQty[0].set("v.value",ProductQty[0].get("v.value") - component.get("v.MapCounterToSchQty")[0].ScheduledQty);
                    Prdunch=ProductUnschQty[0];  
                }else{
                    ProductUnschQty.set("v.value",ProductQty.get("v.value") - component.get("v.MapCounterToSchQty")[0].ScheduledQty);
                    Prdunch=ProductUnschQty; 
                }
                if(Prdunch.get("v.value")==0){
                    Prdunch.set("v.class",'unchGreen');
                }
                if(Prdunch.get("v.value")>0){
                    Prdunch.set("v.class",'unchYellow');
                }
                if(Prdunch.get("v.value")<0){
                    Prdunch.set("v.class",'unchRed');
                }
            }  */
    },
    ValidationBeforeSubmit : function(component,event,helper){
        var Validated=true;
        var ProductUnschQty = component.find("ProductUnsch"); 
        var qtyTypNullCheck=component.find("qtyType");
        var monthlyFee = component.find("ProductUnit");
        var onetimefee = component.find("OneTimeFee");
        var prdQty=component.find("ProductQty");
        var qtyTyp = component.get("v.qtyTyp");
        
        var numOfTerm=component.find("NumberOfTerms");
       
         var dataValues = component.get("v.dataList");
      
        if(component.get("v.dataList").length>1){
            for(var i=0;i<ProductUnschQty.length;i++ ){ 
                if(ProductUnschQty[i].get("v.value")<0){
                    Validated=false;
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "The sum of Sub Quantity cannot be greater than the Total Quantity. Please make the adjustments and save again.",
                        "Category" : "Error",
                        "isShow" : "True" 
                    });
                    FloatMsgEvent.fire();
                    break;
                }
            }  
        }
        
        
        // by stuti -- for bug 2279 : negative values should not be saved
        
           if(component.get("v.dataList").length > 0 && Validated) {
           		var dataValues = component.get("v.dataList");
                
                if(component.get("v.isCatm") == true && component.get("v.dataList").length > 0) {
                    var dataValues = component.get("v.dataList");
                    var CATMOpp =  component.get("v.isCatm");
           
          
                dataValues.forEach((item, index) => {                                     
                        if(!$A.util.isEmpty(component.get("v.dataList")[index].MonthlyFee) && parseFloat(component.get("v.dataList")[index].MonthlyFee) != 0 && !$A.util.isEmpty(component.get("v.dataList")[index].OneTimeFee) && parseFloat(component.get("v.dataList")[index].OneTimeFee) != 0) {
                            var monthlyFee = component.find("ProductUnit");
                            var onetimefee = component.find("OneTimeFee");
                            if($A.util.isArray(monthlyFee)) {
                                    monthlyFee[index].set("v.errors", [{message:"One time or monthly fee allowed"}]);
                            }  else {
                                monthlyFee.set("v.errors", [{message:"One time or monthly fee allowed"}]);
                            } 
                            
                            if($A.util.isArray(onetimefee)) {
                                onetimefee[index].set("v.errors", [{message:"One time or monthly fee allowed"}]);
                            } else {
                                onetimefee.set("v.errors", [{message:"One time or monthly fee allowed"}]);    
                            }        
                            Validated=false;
                        } 
                });
    		
            if(!Validated) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Both one Time Fee and Monthly fee available for some products. Please make the adjustments and save again.",
                    "type":"error"
                });
                toastEvent.fire();
            }
        }
          
            if(Validated) {      
                    dataValues.forEach((item, index) => {                                     
                    if(!$A.util.isEmpty(component.get("v.dataList")[index].MonthlyFee) && parseFloat(component.get("v.dataList")[index].MonthlyFee) < 0 || !$A.util.isEmpty(component.get("v.dataList")[index].OneTimeFee) && parseFloat(component.get("v.dataList")[index].OneTimeFee) < 0 || !$A.util.isEmpty(component.get("v.dataList")[index].Quantity) && parseFloat(component.get("v.dataList")[index].Quantity) < 0 || !$A.util.isEmpty(component.get("v.dataList")[index].NumberOfTerms) && parseFloat(component.get("v.dataList")[index].NumberOfTerms) < 0 || !$A.util.isEmpty(component.get("v.dataList")[index].UnitPrice) && parseFloat(component.get("v.dataList")[index].UnitPrice) < 0 || !$A.util.isEmpty(component.get("v.dataList")[index].ProductUnschQty) && parseFloat(component.get("v.dataList")[index].ProductUnschQty) <= -1) {
                                /*var monthlyFee = component.find("ProductUnit");
                                var onetimefee = component.find("OneTimeFee");
                                if($A.util.isArray(monthlyFee)<0) {
                                        monthlyFee[index].set("v.errors", [{message:"monthly fee can't be negative"}]);
                                }  
                                
                                if($A.util.isArray(onetimefee)<0) {
                                    onetimefee[index].set("v.errors", [{message:"One time can't be negative"}]);
                                } */       
                                Validated=false;
                            } 
                    });
                    
                    if(!Validated) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": " Negative value can't be saved. Please make the adjustments and save again.",
                            "type":"error"
                        });
                        toastEvent.fire();
                    }
            }
        }
        
        // end
        
        /*if(component.get("v.isCatm")){
           if(component.get("v.dataList").length>=0){
            for(var i=0;i<qtyTypNullCheck.length;i++ ){ 
                if(qtyTypNullCheck[i].get("v.value")=="" ||
                   
                   $A.util.isEmpty(component.find("qtyType"))
                  
                  ){ 
                    
                    Validated=false;
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : " Qty Type is required. Please select appropriate value",
                        "Category" : "Error",
                        "isShow" : "True" 
                    });
                    FloatMsgEvent.fire();
                    break;
                }
            }  
        }
        }*/
        
     if(component.get("v.isCatm") && Validated) {
         
         if(component.get("v.dataList").length > 0){
              
                var dataValues = component.get("v.dataList");
                dataValues.forEach((item, index) => {                                     
                        if($A.util.isEmpty(component.get("v.dataList")[index].qtyTyp)){         
                            Validated=false;
                        } 
                });
                
                if(!Validated) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Qty Type is required. Please select appropriate value",
                        "type":"error"
                    });
                    toastEvent.fire();
                }
            }
     }





        if(component.get("v.dataList").length == 1 && Validated) {
            if(component.find("ProductUnsch")[0]){
                if(component.find("ProductUnsch")[0].get("v.value")<0){
                    Validated=false;
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "The sum of Sub Quantity cannot be greater than the Total Quantity. Please make the adjustments and save again.",
                        "Category" : "Error",
                        "isShow" : "True" 
                    });
                    FloatMsgEvent.fire(); 
                }
                
            }else if(ProductUnschQty.get("v.value")<0){
                Validated=false;
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Value cannot be in negative. Please adjust highlighted values and save again.",
                    "Category" : "Error",
                    "isShow" : "True" 
                });
                FloatMsgEvent.fire();  
            }
        }
        return Validated;
    },
    CreateJason : function(component,event,helper){
        debugger;
        var ScheduleDateOpp;  
        if(component.get("v.scheduleHeader").length>0){
            var monthyear = component.get("v.scheduleHeader")[0].label.split('-');
            ScheduleDateOpp = monthyear[1]+'-'+monthyear[0]+'-'+1;
            
        }
        component.set("v.toggleSpinner",true);
        var inputScheduleValue = component.get("v.dataList");
        var testJson = '{"OpportunityLineItem": [';
        for(var i=0; i<inputScheduleValue.length; i++){
            console.log(inputScheduleValue[i]);
            //alert(Math.round(inputScheduleValue[i].UnitPrice));
            testJson += '{';
            testJson += '"Id"'+ ':"' +inputScheduleValue[i].productID+'",'; 
            testJson += '"isSubscriptioned"' + ":"+inputScheduleValue[i].isSubscriptioned+",";
            testJson += '"Quantity"' + ":"+Math.round(inputScheduleValue[i].Quantity)+",";
            testJson += '"UnitPrice"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].UnitPrice)) ? 0 :inputScheduleValue[i].UnitPrice)+",";//Changes done for Monthly fee- remove math.round
            testJson += '"TotalPrice"' + ":"+Math.round(inputScheduleValue[i].TotalPrice)+",";
            //done by Sushant starts
            testJson += '"RevenueType"' + ":"+ '"' +encodeURI(inputScheduleValue[i].RevenueType)+'"' + ",";
            testJson += '"TotalACVPrice"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].TotalACVPrice)) ? 0 : (inputScheduleValue[i].TotalACVPrice))+",";
            testJson += '"TotalTCVPrice"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].TotalTCVPrice)) ? 0 : (inputScheduleValue[i].TotalTCVPrice))+","; //Changes done for Monthly fee- remove math.round
            testJson += '"NumberOfTerms"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].NumberOfTerms)) ? 0 : Math.round(inputScheduleValue[i].NumberOfTerms))+",";
            testJson += '"OneTimeFee"' + ":"+	(Number.isNaN(Math.round(inputScheduleValue[i].OneTimeFee)) ? 0 : (inputScheduleValue[i].OneTimeFee))+","; //Changes done for Monthly fee- remove math.round
            testJson += '"MonthlyFee"' + ":"+	(Number.isNaN(Math.round(inputScheduleValue[i].MonthlyFee)) ? 0 : (inputScheduleValue[i].MonthlyFee))+",";
            //done by Sushant ends
            //PACKAGE CONFIG FIELDS
            //testJson += '"isPackage"'+ ':"' +inputScheduleValue[i].isPackage+'",'; 
            //testJson += '"isCompanion"'+ ':"' +inputScheduleValue[i].isCompanion+'",'; 
            //estJson += '"NumberOfLicense"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].NumberOfLicense)) ? 0 : Math.round(inputScheduleValue[i].NumberOfLicense))+",";
            //masking sites with Quantity
            //testJson += '"NumberOfSites"' + ":"+(Number.isNaN(Math.round(inputScheduleValue[i].Quantity)) ? 0 : Math.round(inputScheduleValue[i].Quantity))+",";
            //testJson += '"MasterLineId"'+ ':"' +inputScheduleValue[i].MasterLineId+'",';            
            //PACKAGE CONFIG FIELDS END
            testJson += '"ProductName"' + ":"+ '"' +encodeURI(inputScheduleValue[i].Name)+'"' + ",";
            testJson += '"UnschldQty"' + ":"+ '"' +inputScheduleValue[i].Unscheduled_Quantity+'"' + ",";
            testJson += '"ScheduleDate"' + ":"+ '"' +ScheduleDateOpp+'"'  + ",";            
            testJson += '"OpportunityId"' + ":"+ '"' +component.get("v.OppId")+'"'  + ",";
            testJson += '"qtyTyp"'+":"+ '"' +inputScheduleValue[i].qtyTyp+'"'  + ",";
            testJson += '"isCATMProduct"' + ":"+inputScheduleValue[i].isCATMProduct+","; 
            testJson += '"OpportunityLineItemSchedule": ['; 
            
            for(var j=0;j<inputScheduleValue[i].Schedules.length;j++){
                
                var monthyear = inputScheduleValue[i].Schedules[j].schLabel.split('-');
                var scheduleaDate = monthyear[1]+'-'+monthyear[0]+'-'+1;
                testJson+='{';
                if((inputScheduleValue[i].Schedules[j].Quantity))
                    testJson += '"Quantity"' + ":"+inputScheduleValue[i].Schedules[j].Quantity+",";
                testJson += '"Id"'+ ':"' +inputScheduleValue[i].Schedules[j].ScheduleID+'",';	
                testJson += '"ScheduleDate"' + ":"+ '"' +scheduleaDate+'"';
                
                if( j === inputScheduleValue[i].Schedules.length - 1){ 
                    testJson += '}'; 
                }		else{
                    testJson += '},';      
                }
                
            } 
            
            testJson += ']';
            if( i == inputScheduleValue.length - 1){ 
                testJson += '}';
            }else{
                testJson += '},';      
            } 
        }
        testJson += ']}';
        console.log('testJson'+testJson);
        debugger ;
        var action = component.get("c.SubmitManegeSchedule"); 
        action.setParams({      
            JsonStringSubmit : testJson      
        }); 
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue() === "SUCCESS"){
                    component.set("v.toggleSpinner","false");
                   /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Schedule updated succesfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire(); */
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Schedule Updated Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                    helper.changeHeaderColorAfterSave( component, event, helper );                    
                    component.set("v.ToggleReadOnly",true);
                    
                    /* var validateAmtPSComp = $A.get("e.c:EventToValidateMsg");
                         validateAmtPSComp.setParams({
                                "preSubmit" : "preSubmit"});
                         validateAmtPSComp.fire();*/  
                }else{
                    component.set("v.toggleSpinner",false);
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : a.getReturnValue(),
                        "Category" : "Error",
                        "isShow" : "True"
                    });*/
                    //FloatMsgEvent.fire();
                    //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Error!",
       		 		"message": a.getReturnValue(),
        			"type":"error"
   			 		});
    				toastEvent.fire();

                }   
            }
            else{ 
                component.set("v.toggleSpinner",false);
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Technical error occurred on server. Please report to NSC Administration (NSC.Administration@ncr.com).",
                    "Category" : "Error",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    },
    getOpportunityById : function(component,event,helper){
        var action = component.get("c.getOpportunityById");  
        action.setParams({
            OppId : component.get("v.OppId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set("v.EDD",response.getReturnValue().Expected_Delivery_Date__c);
                component.set("v.EBD",response.getReturnValue().CloseDate);
                component.set("v.OppName",response.getReturnValue().Name);
                if(response.getReturnValue().StageName=='Open'){
                    component.set("v.ToggleReadOnly",false);
                }
                else if(response.getReturnValue().StageName=='Close')
                    component.set("v.ToggleReadOnly",true);
                
                console.log( response.getReturnValue() );
                console.log( response.getReturnValue().isClosed );
            }
        });
        $A.enqueueAction(action);
    },
    OpenCopyPasteWindowHelper:function(component,event,helper){
        
        var idx = event.currentTarget;
        var idd=parseInt(idx.dataset.ids);
        
        component.set("v.ShowHideCopyModel",true);  
        component.set("v.hideIndex",idd);
        
        component.set("v.dataListCopy",component.get("v.dataList"));
        console.log(component.get("v.dataListCopy"));
        var ProductDataList=component.get("v.dataList"); 
        var ProductUnitPrice= component.find("ProductUnit");
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        ///////////////////////////done by Sushant/////////////////
        var ProductTotalTCVPrice= component.find("TotalTCVPrice");
        var ProductTotalACVPrice= component.find("TotalACVPrice");
        var ProductNumberOfTerms= component.find("NumberOfTerms");
        var ProductOneTimeFee= component.find("OneTimeFee");
        
        /////////////////done by sushant ends//////////////////////
        var ProductUnschQty = component.find("ProductUnsch");
        component.find("SchedulerSection").set("v.value",false);
        
    },
    CancelCopyWindowHelper:function(component,event,helper){
        component.set("v.ShowHideCopyModel",false);
        component.set("v.showDistributeBuutons", true);
        var arr = component.find("TheCheckBox"); 
        for( var i=0; i<arr.length; i++ ){ 
            if(component.find("TheCheckBox")[i].get("v.value")){
                //component.find("TheCheckBox")[i].set("v.value") = false;
                var resultCmp = component.find("TheCheckBox")[i];
                resultCmp.set("v.value", false );
            }
        }
        
    },   
    pasteDatahelper:function(component,event,helper){
        
        var ProductDataList = component.get("v.dataList"); 
        var copyIndex=component.get("v.hideIndex");
        var arr = component.find("TheCheckBox"); 
        var SumOfSchedule=0;
        var newMapCounterToSchQty=[];
        for( var k=0; k < ProductDataList[copyIndex].Schedules.length ; k++ ){
            if(ProductDataList[copyIndex].Schedules[k].Quantity != null)
                SumOfSchedule=SumOfSchedule+ProductDataList[copyIndex].Schedules[k].Quantity;
        }   
        
        var dataObj = [];
        
        for( var i=0; i<arr.length; i++ ){
            if(component.find("TheCheckBox")[i].get("v.value")){
                dataObj.push(
                    {
                        Counter : i,
                        productID:ProductDataList[i].productID,
                        Name:ProductDataList[i].Name,
                        UnitPrice:ProductDataList[i].UnitPrice,
                        //Quantity:ProductDataList[i].Quantity, 
                        Quantity:ProductDataList[i].isPackage == true ? ProductDataList[i].NumberOfSite : ProductDataList[i].Quantity,
                        TotalPrice:ProductDataList[i].TotalPrice,  
                        //done by sushant
                        TotalACVPrice:ProductDataList[i].TotalACVPrice,
                        TotalTCVPrice:ProductDataList[i].TotalTCVPrice,
                        NumberOfTerms:ProductDataList[i].NumberOfTerms,
                        OneTimeFee:ProductDataList[i].OneTimeFee,
                        MonthlyFee:ProductDataList[i].MonthlyFee,
                        //done by sushant ends
                        Unscheduled_Quantity:ProductDataList[i].Quantity-SumOfSchedule,
                        UnchStyleClass :ProductDataList[i].Quantity > ProductDataList[copyIndex].Quantity ? 'unchYellow' : ProductDataList[i].Quantity < ProductDataList[copyIndex].Quantity ? 'unchRed' : 'unchGreen' ,
                        RevenueType : ProductDataList[i].RevenueType ,
                        isSubscriptioned : ProductDataList[i].isSubscriptioned , 
                        mandateSubscriptioned:ProductDataList[i].mandateSubscriptioned,
                        //Subscription Package 
                        qtyTyp:ProductDataList[i].qtyTyp, //by Stuti
                        isCATMProduct: ProductDataList[i].isCATMProduct,
                       /* isPackage:ProductDataList[i].isPackage,
                        isCompanion:ProductDataList[i].isCompanion,
                        NumberOfLicense:ProductDataList[i].NumberOfLicense,
                        NumberOfSite:ProductDataList[i].NumberOfSite,
                        MasterLineId:ProductDataList[i].MasterLineId,  */
                        Schedules:[] 
                    } 
                );
                
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity
                });
                
                for( var j=0; j < ProductDataList[i].Schedules.length ; j++ ){
                    if( dataObj[i].productID == ProductDataList[i].Schedules[j].productID ){
                        dataObj[i].Schedules.push(
                            { 
                                ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                Quantity:ProductDataList[copyIndex].Schedules[j].Quantity,
                                productID:ProductDataList[i].Schedules[j].productID,
                                schLabel:ProductDataList[i].Schedules[j].schLabel
                            }
                        );    
                    } 
                }
            } 
            
            else{
                dataObj.push(
                    {
                        Counter : i,
                        productID:ProductDataList[i].productID,
                        Name:ProductDataList[i].Name,
                        UnitPrice:ProductDataList[i].UnitPrice,
                        //Quantity:ProductDataList[i].Quantity,
                        Quantity:ProductDataList[i].isPackage == true ? ProductDataList[i].NumberOfSite : ProductDataList[i].Quantity,
                        TotalPrice:ProductDataList[i].TotalPrice,
                        //done by sushant
                        TotalACVPrice:ProductDataList[i].TotalACVPrice,
                        TotalTCVPrice:ProductDataList[i].TotalTCVPrice,
                        NumberOfTerms:ProductDataList[i].NumberOfTerms,
                        OneTimeFee:ProductDataList[i].OneTimeFee,
                        MonthlyFee:ProductDataList[i].MonthlyFee,
                        //done by sushant ends
                        Unscheduled_Quantity:ProductDataList[i].Unscheduled_Quantity,
                        UnchStyleClass :ProductDataList[i].UnchStyleClass,
                        RevenueType : ProductDataList[i].RevenueType ,
                        isSubscriptioned : ProductDataList[i].isSubscriptioned ,
                        mandateSubscriptioned:ProductDataList[i].mandateSubscriptioned,
                        qtyTyp:ProductDataList[i].qtyTyp,
                        isCATMProduct: ProductDataList[i].isCATMProduct,
                        //Subscription Package 
                        /*isPackage:ProductDataList[i].isPackage,
                        isCompanion:ProductDataList[i].isCompanion,
                        NumberOfLicense:ProductDataList[i].NumberOfLicense,
                        NumberOfSite:ProductDataList[i].NumberOfSite,
                        MasterLineId:ProductDataList[i].MasterLineId, */
                        Schedules:[]
                    }
                ); 
                
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity
                });
                
                for( var j=0; j < ProductDataList[i].Schedules.length ; j++ ){
                    if( dataObj[i].productID == ProductDataList[i].Schedules[j].productID ){
                        dataObj[i].Schedules.push(
                            {  
                                ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                Quantity:ProductDataList[i].Schedules[j].Quantity,
                                productID:ProductDataList[i].Schedules[j].productID,
                                schLabel:ProductDataList[i].Schedules[j].schLabel  
                            }
                        );    
                    }
                }
            }     
        }
        component.set("v.dataList",dataObj);  
        component.set("v.ShowHideCopyModel",false);
        component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        component.set("v.showDistributeBuutons", true); 
        this.EnableSubmit(component,event,helper);
    },
    
    selectAllcheckBoxhelper:function(component,event,helper){ 
        var arr = component.find("TheCheckBox")
        if(component.find("SchedulerSection").get("v.value")){
            for(var i=0; i<arr.length; i++){
                component.find("TheCheckBox")[i].set("v.value",true);
            }
        } 
        else{
            
            for(var i=0; i<arr.length; i++){ 
                component.find("TheCheckBox")[i].set("v.value",false);
            }
        }
        
    }, 
    distributeDatahelper:function(component,event,helper){
        var ProductDataList = component.get("v.dataList"); 
        var copyIndex=component.get("v.hideIndex"); 
        var arr = component.find("TheCheckBox"); 
        var dataObj = [];
        var newMapCounterToSchQty=[]; 
        //calculate Copy index unschedule Quantity percent.
        var schedulepercent = Math.round((ProductDataList[copyIndex].Unscheduled_Quantity / ProductDataList[copyIndex].Quantity) * 100);
        
        
        for( var i=0; i<arr.length; i++ ){ 
            
            if(component.find("TheCheckBox")[i].get("v.value")){
                
                var unscheduleQuantity = Math.round((ProductDataList[i].Quantity * schedulepercent) / 100); 
                //alert('unscheduleQuantity'+unscheduleQuantity);
                var temp1=unscheduleQuantity;
                dataObj.push( 
                    {
                        Counter : i,
                        productID:ProductDataList[i].productID, 
                        Name:ProductDataList[i].Name,
                        UnitPrice:ProductDataList[i].UnitPrice,
                        //Quantity:ProductDataList[i].Quantity,
                        Quantity:ProductDataList[i].isPackage == true ? ProductDataList[i].NumberOfSite : ProductDataList[i].Quantity,
                        TotalPrice:ProductDataList[i].TotalPrice,
                        //done by sushant
                        TotalACVPrice:ProductDataList[i].TotalACVPrice,
                        TotalTCVPrice:ProductDataList[i].TotalTCVPrice,
                        NumberOfTerms:ProductDataList[i].NumberOfTerms,
                        OneTimeFee:ProductDataList[i].OneTimeFee,
                        MonthlyFee:ProductDataList[i].MonthlyFee,
                        //done by sushant ends
                        Unscheduled_Quantity:unscheduleQuantity,
                        UnchStyleClass :ProductDataList[copyIndex].UnchStyleClass, 
                        RevenueType : ProductDataList[i].RevenueType ,
                        isSubscriptioned :  ProductDataList[i].isSubscriptioned ,
                        mandateSubscriptioned:ProductDataList[i].mandateSubscriptioned,
                        qtyTyp:ProductDataList[i].qtyTyp,
                        isCATMProduct: ProductDataList[i].isCATMProduct,
                        //Subscription Package 
                       /* isPackage:ProductDataList[i].isPackage,
                        isCompanion:ProductDataList[i].isCompanion,
                        NumberOfLicense:ProductDataList[i].NumberOfLicense,
                        NumberOfSite:ProductDataList[i].NumberOfSite,
                        MasterLineId:ProductDataList[i].MasterLineId,*/ 
                        Schedules:[]  
                    } 
                ); 
                //List for holding Index and Total Schedule Qty
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: ProductDataList[i].Quantity - unscheduleQuantity
                });
                var QuantitytoDistribute=Math.round(ProductDataList[i].Quantity);
                
                //alert(QuantitytoDistribute);
                var temp=0;   
                
                for( var j=0; j < ProductDataList[i].Schedules.length ; j++ ){ 
                    
                    if(ProductDataList[copyIndex].Schedules[j].Quantity)
                    {  
                        var fiandPercentage=100*ProductDataList[copyIndex].Schedules[j].Quantity/ProductDataList[copyIndex].Quantity;
                        var valueofSchedule = Math.round(QuantitytoDistribute * fiandPercentage /100);
                        temp1 = temp1+valueofSchedule;
                        if(temp1 <= ProductDataList[i].Quantity ){
                            dataObj[i].Schedules.push(
                                {    
                                    ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                    Quantity: (j == (ProductDataList[i].Schedules.length -1)) ? QuantitytoDistribute - (temp+unscheduleQuantity) : valueofSchedule,
                                    productID:ProductDataList[i].Schedules[j].productID,
                                    schLabel:ProductDataList[i].Schedules[j].schLabel 
                                }  
                            );
                            temp = temp+valueofSchedule;
                        }
                        
                        else{
                            
                            dataObj[i].Schedules.push(
                                {  
                                    ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                    Quantity: ProductDataList[i].Quantity - (temp+unscheduleQuantity), 
                                    productID:ProductDataList[i].Schedules[j].productID,
                                    schLabel:ProductDataList[i].Schedules[j].schLabel 
                                }  
                            ); 
                            
                        }
                        
                    } 
                    else
                    { 
                        
                        dataObj[i].Schedules.push(
                            {  
                                ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                Quantity:0,
                                productID:ProductDataList[i].Schedules[j].productID,
                                schLabel:ProductDataList[i].Schedules[j].schLabel
                            }  
                        );                      
                    }
                    
                }
            }
            
            
            
            else{
                
                dataObj.push(
                    {
                        Counter : i,
                        productID:ProductDataList[i].productID,
                        Name:ProductDataList[i].Name,
                        UnitPrice:ProductDataList[i].UnitPrice,
                        //Quantity:ProductDataList[i].Quantity,
                        Quantity:ProductDataList[i].isPackage == true ? ProductDataList[i].NumberOfSite : ProductDataList[i].Quantity,
                        
                        TotalPrice:ProductDataList[i].TotalPrice,
                        //done by sushant
                        TotalACVPrice:ProductDataList[i].TotalACVPrice,
                        TotalTCVPrice:ProductDataList[i].TotalTCVPrice,
                        NumberOfTerms:ProductDataList[i].NumberOfTerms,
                        OneTimeFee:ProductDataList[i].OneTimeFee,
                        MonthlyFee:ProductDataList[i].MonthlyFee,
                        //done by sushant ends
                        Unscheduled_Quantity:ProductDataList[i].Unscheduled_Quantity,
                        UnchStyleClass :ProductDataList[i].UnchStyleClass,
                        RevenueType : ProductDataList[i].RevenueType ,
                        isSubscriptioned : ProductDataList[i].isSubscriptioned  ,
                        mandateSubscriptioned:ProductDataList[i].mandateSubscriptioned,
                        qtyTyp:ProductDataList[i].qtyTyp,
                        isCATMProduct: ProductDataList[i].isCATMProduct,
                        //Subscription Package 
                        /*isPackage:ProductDataList[i].isPackage,
                        isCompanion:ProductDataList[i].isCompanion,
                        NumberOfLicense:ProductDataList[i].NumberOfLicense,
                        NumberOfSite:ProductDataList[i].NumberOfSite,
                        MasterLineId:ProductDataList[i].MasterLineId, */
                        Schedules:[]
                    } 
                ); 
                
                //List for holding Index and Total Schedule Qty
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity
                });
                
                for( var j=0; j < ProductDataList[i].Schedules.length ; j++ ){
                    if( dataObj[i].productID == ProductDataList[i].Schedules[j].productID){
                        dataObj[i].Schedules.push(
                            {  
                                ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                                Quantity:ProductDataList[i].Schedules[j].Quantity,
                                productID:ProductDataList[i].Schedules[j].productID,
                                schLabel:ProductDataList[i].Schedules[j].schLabel  
                            } 
                        );    
                    }
                }
            }
            
        }
        
        component.set("v.dataList",dataObj);  
        component.set("v.ShowHideCopyModel",false);
        component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        component.set("v.showDistributeBuutons", true); 
        this.EnableSubmit(component,event,helper);
        
    },
    WarningSchBeforeSubmit : function(component,event,helper){
        var TableData = component.get("v.dataList");
        var DateHeader = component.get("v.scheduleHeader");
        for( var i = 0; i < DateHeader.length; i++ ) {
            console.log("Header label"+DateHeader[i].label);
            var counter =0;
            for(var k=0;k<TableData.length;k++){
                for(var j=0;j<TableData[k].Schedules.length;j++){
                    console.log("schedule val for"+TableData[k].Name+"is"+JSON.stringify(TableData[k].Schedules[j]));
                    if(DateHeader[i].label == TableData[k].Schedules[j].schLabel){
                        if($A.util.isEmpty(TableData[k].Schedules[j].Quantity) || $A.util.isUndefined(TableData[k].Schedules[j].Quantity) || TableData[k].Schedules[j].Quantity==0){
                            //console.log("inside if"+TableData[k].Schedules[j].Quantity+"Month"+TableData[k].Schedules[j].schLabel);
                            counter = counter+1; 
                            
                        }
                    } 
                } 
            }
            if(counter == TableData.length){
               /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "You have month without having schedule.",
                    "Category" : "Warning",
                    "isShow" : "True" 
                });
                FloatMsgEvent.fire();*/
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Warning!!",
                    message: 'You have month without having schedule.',
                    type: "Warning"
                });
                toastEvent.fire();
                return true;
            }
        }
        return true;
    },
    toggleReadOnlyViewhelper : function(component,event,helper){
        component.set("v.ToggleReadOnly",true);
    },
    toggleEditViewhelper : function(component,event,helper){
        component.set("v.ToggleReadOnly",false);
    },
    AdjustQuantityHelper:function(component,event,helper){
        var idx = event.currentTarget; 
        var idd=parseInt(idx.dataset.ids); 
        var ProductDataList = component.get("v.dataList");
        var dataObj = [];
        var newMapCounterToSchQty=[];
        var sumOfScheduleQty=[];  
        for(var i=0;i<ProductDataList.length;i++){
            
            var remain=ProductDataList[i].Quantity;
            var partsLeft=ProductDataList[i].Schedules.length;    
            dataObj.push( 
                {
                    Counter : i, 
                    productID:ProductDataList[i].productID, 
                    Name:ProductDataList[i].Name,
                    UnitPrice:ProductDataList[i].UnitPrice,                   
                    // masking Quantity with Sites for scheduling
                    //Quantity:ProductDataList[i].isPackage == true ? ProductDataList[i].NumberOfSites : ProductDataList[i].Quantity,
                    Quantity:ProductDataList[i].Quantity, 
                    TotalPrice:ProductDataList[i].TotalPrice,
                    //done by sushant
                    TotalACVPrice:ProductDataList[i].TotalACVPrice,
                    TotalTCVPrice:ProductDataList[i].TotalTCVPrice,
                    NumberOfTerms:ProductDataList[i].NumberOfTerms,
                    OneTimeFee:ProductDataList[i].OneTimeFee,
                    MonthlyFee:ProductDataList[i].MonthlyFee,
                    //done by sushant ends
                    Unscheduled_Quantity:ProductDataList[i].Counter == idd ? 0 : ProductDataList[i].Unscheduled_Quantity,
                    UnchStyleClass :ProductDataList[i].Counter == idd ? 'unchGreen' : ProductDataList[i].UnchStyleClass,
                    RevenueType : ProductDataList[i].RevenueType ,
                    isSubscriptioned : ProductDataList[i].isSubscriptioned ,
                    mandateSubscriptioned:ProductDataList[i].mandateSubscriptioned,
                    qtyTyp:ProductDataList[i].qtyTyp,
                    isCATMProduct : ProductDataList[i].isCATMProduct,
                    //Subscription Package 
                    /*isPackage:ProductDataList[i].isPackage,
                    isCompanion:ProductDataList[i].isCompanion,
                    NumberOfLicense:ProductDataList[i].NumberOfLicense,
                    NumberOfSite:ProductDataList[i].NumberOfSite,
                    MasterLineId:ProductDataList[i].MasterLineId, */
                    Schedules:[]  
                } 
            );
            //List for holding Index and Total Schedule Qty
            if(ProductDataList[idd].isPackage==true){
                
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: i == idd ? (ProductDataList[i].Quantity*ProductDataList[i].NumberOfLicense) :  (ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity)*ProductDataList[i].NumberOfLicense
                }); 
                
            }else{
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: i == idd ? ProductDataList[i].Quantity :  ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity
                });   
            }
           
            
            for( var j=0; j < ProductDataList[i].Schedules.length ; j++ ){
                // Auto Schedule Push
                if(ProductDataList[i].productID == ProductDataList[i].Schedules[j].productID && ProductDataList[i].Counter == idd){	
                    var size=Math.floor((remain + partsLeft - j - 1) / (partsLeft - j));
                    sumOfScheduleQty.push(ProductDataList[i].Schedules[j].Quantity);
                    dataObj[i].Schedules.push(
                        {   
                            ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                            Quantity: size,
                            productID:ProductDataList[i].Schedules[j].productID,
                            schLabel:ProductDataList[i].Schedules[j].schLabel 
                        }  
                    );
                    
                    remain =remain-size; 
                }  
                else if(ProductDataList[i].productID == ProductDataList[i].Schedules[j].productID){
                    
                    dataObj[i].Schedules.push(
                        {   
            
                            ScheduleID:ProductDataList[i].Schedules[j].ScheduleID,
                            Quantity: ProductDataList[i].Schedules[j].Quantity,
                            productID:ProductDataList[i].Schedules[j].productID,
                            schLabel:ProductDataList[i].Schedules[j].schLabel 
                        }  
                    ); 
                }           
                
            }    
        }
        
        if(sumOfScheduleQty.some(x => x > 0)){
            component.set("v.showhideAutoSchedule",true);
            component.set("v.IndexOfAutoScheduel",idd);
            component.set("v.SchdeuleDataList",dataObj); 
            component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        }  
        
        else{
            component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
            
            ProductDataList.splice(idd,1,dataObj[0]);
            component.set("v.dataList",dataObj); 
            
        } 
        this.EnableSubmit(component,event,helper);
    },
    
    closeAutoSchedule:function(component,event,helper){
        
        component.set("v.showhideAutoSchedule",false); 
    }, 
    recalculateAutoSchdeuleAfterConfirmation:function(component,event,helper){
        var ProductDataList = component.get("v.dataList");
        var idd =component.get("v.IndexOfAutoScheduel"); 
        var backupList=component.get("v.SchdeuleDataList"); 
        var newMapCounterToSchQty=[];
        var newdataList=[];
        for(var i=0;i<backupList.length;i++){
            newdataList.push(
                {
                    Counter : i,
                    productID:backupList[i].productID,
                    Name:backupList[i].Name,
                    UnitPrice:backupList[i].UnitPrice,
                    //Quantity:backupList[i].Quantity,
                    Quantity:backupList[i].Quantity,
                    
                    TotalPrice:backupList[i].TotalPrice,
                    //done by sushant
                    TotalACVPrice:backupList[i].TotalACVPrice,
                    TotalTCVPrice:backupList[i].TotalTCVPrice,
                    NumberOfTerms:backupList[i].NumberOfTerms,
                    OneTimeFee:backupList[i].OneTimeFee,
                    MonthlyFee:ProductDataList[i].MonthlyFee,
                    //done by sushant ends
                    Unscheduled_Quantity:backupList[i].Unscheduled_Quantity,
                    UnchStyleClass : backupList[i].UnchStyleClass,
                    RevenueType : backupList[i].RevenueType ,
                    isSubscriptioned :  backupList[i].isSubscriptioned ,
                    mandateSubscriptioned:backupList[i].mandateSubscriptioned,
                    qtyTyp:backupList[i].qtyTyp,
                    isCATMProduct: backupList[i].isCATMProduct,
                    //Subscription Package 
                    /*isPackage:backupList[i].isPackage,
                    isCompanion:backupList[i].isCompanion,
                    NumberOfLicense:backupList[i].NumberOfLicense,
                    NumberOfSite:backupList[i].NumberOfSite,
                    MasterLineId:backupList[i].MasterLineId, */
                    
                    Schedules:[]
                }
            ); 
            if(ProductDataList[idd].isPackage==true){
                
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: i == idd ? (ProductDataList[i].Quantity*ProductDataList[i].NumberOfLicense) :  (ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity)*ProductDataList[i].NumberOfLicense
                }); 
                
            }else{
                newMapCounterToSchQty.push({
                    key:i,
                    ScheduledQty: i == idd ? ProductDataList[i].Quantity :  ProductDataList[i].Quantity - ProductDataList[i].Unscheduled_Quantity
                });   
            }
           
            for( var j=0; j < backupList[i].Schedules.length ; j++ ){
                if( newdataList[i].productID == backupList[i].Schedules[j].productID ){
                    newdataList[i].Schedules.push(
                        {
                            ScheduleID:backupList[i].Schedules[j].ScheduleID,
                            Quantity:backupList[i].Schedules[j].Quantity,
                            productID:backupList[i].Schedules[j].productID,
                            schLabel:backupList[i].Schedules[j].schLabel
                        }
                    );    
                }
            }   
        }
        this.closeAutoSchedule(component,event,helper);
        component.set("v.MapCounterToSchQty",newMapCounterToSchQty);
        component.set("v.dataList",newdataList); 
    },
    DisableSubmit:function(component,event,helper){
        var cmpTarget = component.find("submitbtn");
        component.set("v.ToggleSubmit",true);
        $A.util.addClass(cmpTarget, 'CursorCustom');
    },
    EnableSubmit:function(component,event,helper){
        var cmpTarget = component.find("submitbtn");
        component.set("v.ToggleSubmit",false);
        $A.util.removeClass(cmpTarget, 'CursorCustom');
        
    },
    ValidateInputs :  function(component,event,helper){
        var Validated=true;
        var ProductUnitPrice= component.find("ProductUnit");
        var ProductTotal= component.find("ProductTotal");
        var ProductQty= component.find("ProductQty");
        //done by sushant
        var ProductTotalTCVPrice=component.find("TotalTCVPrice");
        var ProductNumberOfTerms =component.find("NumberOfTerms");
        var ProductOneTimeFee= component.find("OneTimeFee");
        //done by sushant ends
        var ProductTotalPrice;
        if(component.get("v.dataList").length>1){
            var j=0;
            for(var i=0;i<component.get("v.dataList").length;i++){
                //no validation for package as of now
               /* if((!$A.util.isUndefined(component.get("v.dataList")[i].isPackage) && component.get("v.dataList")[i].isPackage == true) || (!$A.util.isUndefined(component.get("v.dataList")[i].isCompanion) && component.get("v.dataList")[i].isCompanion == true)){
                    j++;
                    continue;  
                } */
                if((!$A.util.isUndefined(component.get("v.dataList")[i].isSubscriptioned) && component.get("v.dataList")[i].isSubscriptioned == true) || 
                   component.get("v.dataList")[i].RevenueType == 'Cloud') {
                    if(!component.get("v.haserror")){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":"error",
                            "title": "Error!",
                            "message": "Please correct the error on screen first."
                        });
                        toastEvent.fire();
                        Validated = false;
                    }
                }
                
                ProductTotalPrice = component.find("ProductTotal")[i];
                if($A.util.isEmpty(ProductTotalPrice.get("v.value")) || $A.util.isUndefined(ProductTotalPrice.get("v.value")) || ProductTotalPrice.get("v.value") < 0){
                    ProductTotalPrice.set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(ProductTotalPrice,'customError');
                    Validated = false;
                }         
                else {
                    ProductTotalPrice.set("v.errors",null);
                    $A.util.removeClass(ProductTotalPrice,'customError');
                }
                debugger;
                // AJAY REMOVING VALIDATION
                
                /*if(!(!$A.util.isUndefined(component.get("v.dataList")[i].isPackage) && component.get("v.dataList")[i].isPackage == true) || (!$A.util.isUndefined(component.get("v.dataList")[i].isCompanion) && component.get("v.dataList")[i].isCompanion == true) && $A.util.isEmpty(ProductUnitPrice[i].get("v.value")) || $A.util.isUndefined(ProductUnitPrice[i].get("v.value")) || ProductUnitPrice[i].get("v.value") < 0){
                    ProductUnitPrice[i].set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(ProductUnitPrice[i],'customError');
                    Validated = false;
                }         
                else {
                    if(!(!$A.util.isUndefined(component.get("v.dataList")[i].isPackage) && component.get("v.dataList")[i].isPackage == true) || (!$A.util.isUndefined(component.get("v.dataList")[i].isCompanion) && component.get("v.dataList")[i].isCompanion == true)){
                        ProductUnitPrice[i].set("v.errors",null);
                   		 $A.util.removeClass(ProductUnitPrice[i],'customError');
                    }
                       
                   
                }*/
                ////////////////////////////////////////////////////done by sushant////////////////////////////////////////////////////////////
                /* 
                   if(component.get("v.dataList")[component.get("v.Counter")].isSubscriptioned == true || 
                    component.get("v.dataList")[component.get("v.Counter")].RevenueType == 'Cloud') 
                   {
                    if($A.util.isEmpty(ProductTotalTCVPrice[i].get("v.value")) || $A.util.isUndefined(ProductTotalTCVPrice[i].get("v.value")) || ProductTotalTCVPrice[i].get("v.value") < 1){
                        ProductTotalTCVPrice[i].set("v.errors", [{message:"Invalid TCV Price"}]);
                        $A.util.addClass(ProductTotalTCVPrice[i],'customError');
                        Validated = false;
                    }         
                    else {
                        ProductTotalTCVPrice[i].set("v.errors",null);
                        $A.util.removeClass(ProductTotalTCVPrice[i],'customError');
                    } 
                    
                    if($A.util.isEmpty(ProductNumberOfTerms[i].get("v.value")) || $A.util.isUndefined(ProductNumberOfTerms[i].get("v.value")) || ProductNumberOfTerms[i].get("v.value") < 1){
                        ProductNumberOfTerms[i].set("v.errors", [{message:"Invalid # of Terms"}]);
                        $A.util.addClass(ProductNumberOfTerms[i],'customError');
                        Validated = false;
                    }         
                    else {
                        ProductNumberOfTerms[i].set("v.errors",null);
                        $A.util.removeClass(ProductNumberOfTerms[i],'customError');
                    }
                    
                     if($A.util.isEmpty(ProductOneTimeFee[i].get("v.value")) || $A.util.isUndefined(ProductOneTimeFee[i].get("v.value")) || ProductOneTimeFee[i].get("v.value") < 1){
                        ProductOneTimeFee[i].set("v.errors", [{message:"Invalid One Time Fee"}]);
                        $A.util.addClass(ProductOneTimeFee[i],'customError');
                        Validated = false;
                    }         
                    else {
                        ProductOneTimeFee[i].set("v.errors",null);
                        $A.util.removeClass(ProductOneTimeFee[i],'customError');
                    } 
                   } */
                ////////////////////////////////////////////done by sushant ends///////////////////////////////////////////////////////////
                
                
                if($A.util.isEmpty(ProductQty[i].get("v.value")) || $A.util.isUndefined(ProductQty[i].get("v.value")) || ProductQty[i].get("v.value") < 0){
                    ProductQty[i].set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(ProductQty[i],'customError');
                    Validated = false;
                }         
                else {
                    ProductQty[i].set("v.errors",null);
                    $A.util.removeClass(ProductQty[i],'customError');
                }
                
            }
        }
        
        
        else if(component.get("v.dataList").length == 1) {
            
            if((!$A.util.isUndefined(component.get("v.dataList")[0].isSubscriptioned) && component.get("v.dataList")[0].isSubscriptioned == true) || 
               component.get("v.dataList")[0].RevenueType == 'Cloud') {
                if(!component.get("v.haserror")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": "Please correct the error on screen first."
                    });
                    toastEvent.fire();
                    Validated = false;
                }
            }
            if(component.find("ProductTotal")[0]){
                if($A.util.isEmpty(component.find("ProductTotal")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductTotal")[0].get("v.value")) || component.find("ProductTotal")[0].get("v.value") < 0){
                    component.find("ProductTotal")[0].set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductTotal")[0],'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductTotal")[0].set("v.errors",null);
                    $A.util.removeClass(component.find("ProductTotal")[0],'customError');
                }
                
                if($A.util.isEmpty(component.find("ProductUnit")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductUnit")[0].get("v.value")) || component.find("ProductUnit")[0].get("v.value") < 0){
                    component.find("ProductUnit")[0].set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductUnit")[0],'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductUnit")[0].set("v.errors",null);
                    $A.util.removeClass(component.find("ProductUnit")[0],'customError');
                }
                
                ////////////////////////////////////////done by sushant starts////////////////////////////////////////
                /*if($A.util.isEmpty(component.find("ProductTotalTCVPrice")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductTotalTCVPrice")[0].get("v.value")) || component.find("ProductTotalTCVPrice")[0].get("v.value") < 0){
                        component.find("ProductTotalTCVPrice")[0].set("v.errors", [{message:"Invalid TCV Price"}]);
                        $A.util.addClass(component.find("ProductTotalTCVPrice")[0],'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductTotalTCVPrice")[0].set("v.errors",null);
                        $A.util.removeClass(component.find("ProductTotalTCVPrice")[0],'customError');
                    }
                    
                    if($A.util.isEmpty(component.find("ProductNumberOfTerms")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductNumberOfTerms")[0].get("v.value")) || component.find("ProductNumberOfTerms")[0].get("v.value") < 0){
                        component.find("ProductNumberOfTerms")[0].set("v.errors", [{message:"Invalid Number of terms"}]);
                        $A.util.addClass(component.find("ProductNumberOfTerms")[0],'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductNumberOfTerms")[0].set("v.errors",null);
                        $A.util.removeClass(component.find("ProductNumberOfTerms")[0],'customError');
                    }
                    if($A.util.isEmpty(component.find("ProductOneTimeFee")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductOneTimeFee")[0].get("v.value")) || component.find("ProductOneTimeFee")[0].get("v.value") < 0){
                        component.find("ProductOneTimeFee")[0].set("v.errors", [{message:"Invalid One Time Fee"}]);
                        $A.util.addClass(component.find("ProductOneTimeFee")[0],'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductOneTimeFee")[0].set("v.errors",null);
                        $A.util.removeClass(component.find("ProductOneTimeFee")[0],'customError');
                    } */
                
                ////////////////////////////////////////done by sushant ends//////////////////////////////////////////
                
                if($A.util.isEmpty(component.find("ProductQty")[0].get("v.value")) || $A.util.isUndefined(component.find("ProductQty")[0].get("v.value")) || component.find("ProductQty")[0].get("v.value") < 0){
                    component.find("ProductQty")[0].set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductQty")[0],'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductQty")[0].set("v.errors",null);
                    $A.util.removeClass(component.find("ProductQty")[0],'customError');
                }
                
            }else{
                if($A.util.isEmpty(component.find("ProductTotal").get("v.value")) || $A.util.isUndefined(component.find("ProductTotal").get("v.value")) || component.find("ProductTotal").get("v.value") < 0){
                    component.find("ProductTotal").set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductTotal"),'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductTotal").set("v.errors",null);
                    $A.util.removeClass(component.find("ProductTotal"),'customError');
                }
                
                if($A.util.isEmpty(component.find("ProductUnit").get("v.value")) || $A.util.isUndefined(component.find("ProductUnit").get("v.value")) || component.find("ProductUnit").get("v.value") < 0){
                    component.find("ProductUnit").set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductUnit"),'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductUnit").set("v.errors",null);
                    $A.util.removeClass(component.find("ProductUnit"),'customError');
                }
                
                ///////////////////////////////////////////done by sushant starts///////////////////////////////////////////
                /* if($A.util.isEmpty(component.find("ProductTotalTCVPrice").get("v.value")) || $A.util.isUndefined(component.find("ProductTotalTCVPrice").get("v.value")) || component.find("ProductTotalTCVPrice").get("v.value") < 0){
                        component.find("ProductTotalTCVPrice").set("v.errors", [{message:"Invalid TCV Price"}]);
                        $A.util.addClass(component.find("ProductTotalTCVPrice"),'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductTotalTCVPrice").set("v.errors",null);
                        $A.util.removeClass(component.find("ProductTotalTCVPrice"),'customError');
                    } 
                    if($A.util.isEmpty(component.find("ProductNumberOfTerms").get("v.value")) || $A.util.isUndefined(component.find("ProductNumberOfTerms").get("v.value")) || component.find("ProductNumberOfTerms").get("v.value") < 0){
                        component.find("ProductNumberOfTerms").set("v.errors", [{message:"Invalid Price"}]);
                        $A.util.addClass(component.find("ProductNumberOfTerms"),'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductNumberOfTerms").set("v.errors",null);
                        $A.util.removeClass(component.find("ProductNumberOfTerms"),'customError');
                    }
                    if($A.util.isEmpty(component.find("ProductOneTimeFee").get("v.value")) || $A.util.isUndefined(component.find("ProductOneTimeFee").get("v.value")) || component.find("ProductOneTimeFee").get("v.value") < 0){
                        component.find("ProductOneTimeFee").set("v.errors", [{message:"Invalid Price"}]);
                        $A.util.addClass(component.find("ProductOneTimeFee"),'customError');
                        Validated = false;
                    }         
                    else {
                        component.find("ProductOneTimeFee").set("v.errors",null);
                        $A.util.removeClass(component.find("ProductOneTimeFee"),'customError');
                    }
                    */
                ///////////////////////////////////////////done by sushant ends/////////////////////////////////////////////
                if($A.util.isEmpty(component.find("ProductQty").get("v.value")) || $A.util.isUndefined(component.find("ProductQty").get("v.value")) || component.find("ProductQty").get("v.value") < 0){
                    component.find("ProductQty").set("v.errors", [{message:"Invalid Price"}]);
                    $A.util.addClass(component.find("ProductQty"),'customError');
                    Validated = false;
                }         
                else {
                    component.find("ProductQty").set("v.errors",null);
                    $A.util.removeClass(component.find("ProductQty"),'customError');
                }
            }
        }
        
        return Validated;
    },
    changeHeaderColorAfterSave : function( component,event,helper ){
        var previousDateHeader = component.get("v.scheduleHeader");
        var newDateHeader = [];
        for( var x=0; x < previousDateHeader.length ; x++ ){
            newDateHeader.push(
                {
                    label:previousDateHeader[x].label,
                    style:''
                }
            );            
        }
        component.set("v.scheduleHeader",newDateHeader);
    },
    /************************************************************/
    checkschedules: function(component, event, helper) {
        var text ;
        var t =  component.get("v.scheduleHeader");
        var products = component.get("v.dataList");
        var m = false;
        var text1 = 'Copy/Distribute';
        var prolength = products.length;
        component.set("v.tooltipcopydist",text1);
        for (var i = 0; i < t.length; i++) {
            m=true;
            component.set("v.toggleautoschedule",false);
        }
        if(m == false){
            text = 'Please Add Month';
            component.set("v.tooltipcopydist",text);
            component.set("v.toggleautoschedule",true);
            component.set("v.tooltipautoschedule",text);
            component.set("v.toggledistschedule",true);
        }
        else
        {
            text = 'Auto Schedule';
            component.set("v.toggleautoschedule",false);
            component.set("v.tooltipautoschedule",text);
            component.set("v.toggledistschedule",false);
        }
        if(prolength == 1)
        {
            component.set("v.toggledistschedule",true);
        }
        
    },
    updateButtonhelper:function(component,event,helper){
        var flag = false;
        var arr = component.find("TheCheckBox");
        console.log(arr);
        for( var i=0; i<arr.length; i++ ){
            console.log(component.find("TheCheckBox")[i].get("v.value"));
            if(component.find("TheCheckBox")[i].get("v.value")){
                flag = true;
                component.set("v.showDistributeBuutons", false); 
                //break;
            }
        }
        if(!flag){
            component.set("v.showDistributeBuutons", true); 
        }
    }, 
    getQuantityTypes: function(component, event) {
        var action = component.get("c.getQtyTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
   /* setPackageId:function(component,event,helper){        
        component.set("v.pkgid",component.get("v.dataList")[event.currentTarget.dataset.ids].productID);
        console.log('*****'+component.get("v.dataList")[event.currentTarget.dataset.ids].productID);
        
    }, */
   
    /************************************************************/
   /* aasFunctionalityAccess : function(component) {
         var action = component.get("c.aasFunctionalityAccess"); 
      action.setCallback(this, function(a) {
          if (a.getState() === "SUCCESS") { 
              var response=a.getReturnValue();
              var responselist=response.length;
              //alert('response: '+JSON.stringify(response));
              //alert(responselist);
              if(responselist > 0){
                  component.set("v.isAdminProfile",true);
              } 
              //alert(component.get("v.isAdminProfile"));
          }
          
          else if (a.getState() === "ERROR") { 
              $A.log("Errors", a.getError());
          }     
      });
      $A.enqueueAction(action);
    }  */ 
         isCatmOpp : function(component, event, helper) {
		 var action = component.get("c.getOpportunity");
        action.setParams({ 
        OppId :component.get("v.OppId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if(state === "SUCCESS") {  
                 var oppRecord = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(oppRecord)) {
                    component.set("v.isCatm",oppRecord.CATM_Record__c);
                    component.set("v.oppMonths",oppRecord.Contract_Term_Mths__c);
                    
                    if($A.util.isUndefinedOrNull(component.get("v.OppCurr"))) {
                    	component.set("v.OppCurr",oppRecord.CurrencyIsoCode);
                    }
                }
                
                console.log('Test JSon'+JSON.stringify(response.getReturnValue()));
            }
     else if(state === "ERROR") {
                
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message) {
                       alert("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('4');
                }
            }
                else{
                    alert('>>>>'+'Please reload the page.');
                }
             //component.set("v.ShowHideSpinner",false);
             
        });     
        $A.enqueueAction(action);
        
                
	},
    ReInitiate:function(component,event,helper){
        var IPT_PartnerCentral = $A.get("$Label.c.IPT_PartnerCentral"); //Partner Community URL Label
        component.set("v.IPTPartnerCommunityUrl", IPT_PartnerCentral);
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunityUser",isCommunity);
        });
        $A.enqueueAction(action);
        
        var url = window.location.href;
        var urlVar = url.split('?');
        console.log('urlVar =='+urlVar);
        var strParams = urlVar[1].split("&");
        var Opportuntyid = strParams[0].split("=")[1];
        var ScreenName = strParams[1].split("=")[1];
        
        //console.log('OppId@@: '+Opportuntyid);
        //console.log('ScreenName@@: '+ScreenName);
        
        if(Opportuntyid !=null && ScreenName!=null){
            component.set("v.ScreenName", ScreenName);
            component.set("v.OppId", Opportuntyid);    
        }
         var getSettingsAction = component.get("c.getSubsOnlyProd");
   		 getSettingsAction.setCallback(this, function(response) {
             
       	if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
            component.set("v.subsOnlyProdNames" ,response.getReturnValue().ProductNames);
            component.set("v.subsOnlyRevenueTypes" ,response.getReturnValue().RevenueTypes);
            //console.log("Subscription Setting loaded.");
        	} else {
            console.log("Failed to load Subscription Setting.");
        	}
    	});
            
        var action = component.get("c.getCurrentDate") ;
        action.setCallback(this, function(response) {
            var state = response.getState() ;
            if(state=='SUCCESS') {
                component.set("v.todayDateVal" , response.getReturnValue() ) ;
                this.prepareTableHelper(component, event, helper , null);
               // helper.aasFunctionalityAccess(component, event, helper);
            }
        }) ;
        
        $A.enqueueAction(getSettingsAction);
        $A.enqueueAction(action);
        
        //Added for showing Package functionality to O4 NSC Admin Only
        /*var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log("success") ;
                var result = response.getReturnValue();
                if(result.Id=='00e70000000x3egAAA'){
                    component.set('v.isAdminProfile',true);
                }
                
            }else{
                console.error("fail:" + response.getError()[0].message); 
            }
        });
        $A.enqueueAction(action); */
    },
    
    vldCATMOneTimevsMonhtlyFee : function(component,event,helper) {      
        var dataValues = component.get("v.dataList");
        var CATMOpp =  component.get("v.isCatm");
        
        dataValues.forEach((item, index) => {
                var counterIndex = index;
                
                if(!$A.util.isEmpty(component.get("v.dataList")[counterIndex].MonthlyFee) && parseInt(component.get("v.dataList")[counterIndex].MonthlyFee) != 0 && !$A.util.isEmpty(component.get("v.dataList")[counterIndex].OneTimeFee) && parseInt(component.get("v.dataList")[counterIndex].OneTimeFee) != 0) {
        			
        			var monthlyFee = component.find("ProductUnit");
            		var onetimefee = component.find("OneTimeFee");
        			monthlyFee[index].set("v.errors", [{message:"One time or monthly fee allowed"}]);
        			onetimefee[index].set("v.errors", [{message:"One time or monthly fee allowed"}]);
                } 
        });   
	}, 
        
    calcTotalTCV : function(cmp) {    
    	 var dataValues = cmp.get("v.dataList");
         var totalTCV = 0.00;        
         dataValues.forEach((item, index) => {
             totalTCV += $A.util.isEmpty(item.TotalTCVPrice) ? 0 : parseFloat(item.TotalTCVPrice);
         }); 
        cmp.set("v.totalTCV",totalTCV);
    }


})