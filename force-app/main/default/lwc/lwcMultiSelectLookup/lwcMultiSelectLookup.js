import { LightningElement, api, track } from 'lwc';
import retrieveRecords from '@salesforce/apex/MultiSelectLookupController.retrieveRecords';

let i=0;
export default class LwcMultiSelectLookup extends LightningElement {
		
		@api selectedvalue; //monika 

    @track globalSelectedItems = []; //holds all the selected checkbox items
    //start: following parameters to be passed from calling component
    @api labelName;
		@api helpTextValue;  //eba-sf 1715
    @api objectApiName; //
		@api recordId='';
    @api oppId='';
    @api oppName='';
    @api fieldApiNames; // = 'Id,Name';
    @api filterFieldApiName;    // = 'Name';
    @api iconName;  // = 'standard:contact';
    @api showavatar = false;
    //end---->
    @track items = []; //holds all records retrieving from database
    @track selectedItems = []; //holds only selected checkbox items that is being displayed based on search

    //since values on checkbox deselection is difficult to track, so workaround to store previous values.
    //clicking on Done button, first previousSelectedItems items to be deleted and then selectedItems to be added into globalSelectedItems
    @api previousSelectedItems = []; 
    @track value = []; //this holds checkbox values (Ids) which will be shown as selected
    searchInput ='';    //captures the text to be searched from user input
    isDialogDisplay = false; //based on this flag dialog box will be displayed with checkbox items
    isDisplayMessage = false; //to show 'No records found' message
   // @track recordIds=[];
   // @track recordNames=[];
   @api  oppValues=[];
   @api  contactGlobalSelectedItems=[];
   @api  leadGlobalSelectedItems=[];
   @api  userGlobalSelectedItems=[];
   @api  oppGlobalSelectedItems=[];
     connectedCallback() {
         if(this.objectApiName =='Contact' && this.contactGlobalSelectedItems !=[]){
            this.globalSelectedItems.push(...this.contactGlobalSelectedItems);
         }

         if(this.objectApiName =='Lead' && this.leadGlobalSelectedItems !=[]){
            this.globalSelectedItems.push(...this.leadGlobalSelectedItems);
         }

         if(this.objectApiName =='User' && this.userGlobalSelectedItems !=[]){
            this.globalSelectedItems.push(...this.userGlobalSelectedItems);
         }

         if(this.objectApiName =='Opportunity' && this.oppGlobalSelectedItems !=[]){
              
             if(this.oppId !=''){   
             let arr= {"value":this.oppId,"label":this.oppName};
             let arr1=[];
             arr1.push(this.oppId);
               
             this.oppGlobalSelectedItems.map(element=>{
                this.oppValues.push(element.value);
                });
               // alert(this.oppValues);   
                arr1.push(this.oppId);
                let isFounded =  this.oppValues.some( ai => arr1.includes(ai) ); 
               if(!isFounded)  
             this.globalSelectedItems.push(arr);
            }
            this.globalSelectedItems.push(...this.oppGlobalSelectedItems);
         }
        
     }

    //This method is called when user enters search input. It displays the data from database.
    onchangeSearchInput(event){
      
        this.showavatar=true;
        this.searchInput = event.target.value;
				
        if(this.searchInput.trim().length>0){
            //retrieve records based on search input
            retrieveRecords({objectName: this.objectApiName,
                            fieldAPINames: this.fieldApiNames,
                            filterFieldAPIName: this.filterFieldApiName,
                            strInput: this.searchInput,
														objid: this.recordId
                            })
            .then(result=>{ 
                this.items = []; //initialize the array before assigning values coming from apex
                this.value = [];
                this.previousSelectedItems = [];
															 

                if(result.length>0 && this.objectApiName !='Opportunity'){
										
                    result.map(resElement=>{
												//alert(resElement.recordEmail);
												if(resElement.recordEmail != undefined)
                         {
                          this.items = [...this.items,{value:resElement.recordId, 
                                                    label:resElement.recordName+' '+'-'+' '+resElement.recordEmail}];
                           }
												else{
														 this.items = [...this.items,{value:resElement.recordId, 
                                                    label:resElement.recordName}];
												}

                        this.globalSelectedItems.map(element =>{
                            if(element.value == resElement.recordId){
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);                      
                            }
                        });
                    });
                    this.isDialogDisplay = true; //display dialog
                    this.isDisplayMessage = false;
                }
								 else if(result.length>0 && this.objectApiName =='Opportunity'){
                    result.map(resElement=>{
                        //prepare items array using spread operator which will be used as checkbox options
                        this.items = [...this.items,{value:resElement.recordId, 
                                                    label:resElement.recordName+' '+'-'+' '+resElement.recordOppId}];

                        this.globalSelectedItems.map(element =>{
                            if(element.value == resElement.recordId){
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);                      
                            }
                        });
                    });
                    this.isDialogDisplay = true; //display dialog
                    this.isDisplayMessage = false;
                }
                else{
                    //display No records found message
                    this.isDialogDisplay = false;
                    this.isDisplayMessage = true;                    
                }
            })
            .catch(error=>{
                this.error = error;
                this.items = undefined;
                this.isDialogDisplay = false;
            })
        }else{
            this.isDialogDisplay = false;
        }                
    }

    //This method is called during checkbox value change
    handleCheckboxChange(event){
        let selectItemTemp = event.detail.value;       
        this.selectedItems = []; //it will hold only newly selected checkbox items.        

        selectItemTemp.map(p=>{            
            let arr = this.items.find(element => element.value == p);
            if(arr != undefined){
                this.selectedItems.push(arr);
                this.handleDoneClick(event);
            }  
        });     
    }

    //this method removes the pill item
    handleRemoveRecord(event){        
        const removeItem = event.target.dataset.item; //"0032v00002x7UEHAA2"
        
        //this will prepare globalSelectedItems array excluding the item to be removed.
        this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value  != removeItem);
        const arrItems = this.globalSelectedItems;

        //initialize values again
        this.initializeValues();
        this.value =[]; 

        //propagate event to parent component
        const evtCustomEvent = new CustomEvent('remove', {   
            detail: {removeItem,arrItems}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    //Done dialog button click event prepares globalSelectedItems which is used to display pills
    handleDoneClick(event){
        //remove previous selected items first as there could be changes in checkbox selection
        this.previousSelectedItems.map(p=>{
            this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != p.value);
        });
        
       // alert('SI3: '+ this.selectedItems);
        //now add newly selected items to the globalSelectedItems
        this.globalSelectedItems.push(...this.selectedItems);    
       // alert('GSI: '+ this.globalSelectedItems);    
        const arrItems = this.globalSelectedItems;
				
        
        //store current selection as previousSelectionItems
        this.previousSelectedItems = this.selectedItems;
       // this.initializeValues();
        
        //propagate event to parent component
        const evtCustomEvent = new CustomEvent('retrieve', { 
            detail: {arrItems}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    //Cancel button click hides the dialog
    handleCancelClick(event){
        this.initializeValues();
    }

    //this method initializes values after performing operations
    initializeValues(){
        this.searchInput = '';        
        this.isDialogDisplay = false;
    }
}