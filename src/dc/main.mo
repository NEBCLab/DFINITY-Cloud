import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Error "mo:base/Error";

//suppose the file name will not be repeat

actor Main{
    //hash table
    //User & file addr_ databse : Principal -> HashMap; HashMap - > file_name - file_addressk
    private var fileAssets = HashMap.HashMap<Principal, HashMap.HashMap<Text, Text>>(1, Principal.equal, Principal.hash);
    
    //file name -> file owner
    private var name_owner = HashMap.HashMap<Text, Principal>(1, Text.equal, Text.hash);

    //file_name -> file address
    private var name_address = HashMap.HashMap<Text, Text>(1, Text.equal, Text.hash);

    //file name : bool -> true : public false : private
    //private var fileViewable = HashMap.HashMap<Text, Bool>(1, Text.equal, Text.hash);

    //view users : file_name -> hashTable(view_users' Principal - Bool : true -> can | false - can not)
    private var viewer = HashMap.HashMap<Text, HashMap.HashMap<Principal, Bool>>(1, Text.equal, Text.hash);

    //change users : file_name -> hashTable(change_users' Principal -> Bool)
    private var changer = HashMap.HashMap<Text, HashMap.HashMap<Principal, Bool>>(1, Text.equal, Text.hash);

    //delegate users
    //user - Principal -> hashmap(delegate-Principal -> Bool)
    //private var delegates = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Bool>>(1, Principal.equal, Principal.hash);

    // create account  finished                                     
    public shared(msg) func createAccount() : async Text{
        switch(fileAssets.get(msg.caller)){
            case(?fileAsset){
                "you have had a account already";
            };
            case(_){
                var temp = HashMap.HashMap<Text, Text>(1,Text.equal, Text.hash);
                fileAssets.put(msg.caller, temp);
                "create account successfully";
            };
        };
    };
    
    //delete account finished
    public shared(msg) func deleteAccount() : async Text{
        switch(fileAssets.get(msg.caller)){
            case(?fileAsset){
                fileAssets.delete(msg.caller);
                "you have delete your account successfully already, thank you for your using"; 
            };
            case(_){
                "you do not have a account now, please create your Account firstly";
            };
        };
    };

    // wheather have a account : true / false //user : Principal
    private func haveAccount(user : Principal) : Bool{
        switch(fileAssets.get(user)){
            case(?fileAsset){
                true;
            };
            case(_){
                false;
            };
        };
    };

// need finished
    public shared(msg) func uploadFile(file_name : Text, addr_ : Text) : async Text{
        //have account
        switch (fileAssets.get(msg.caller)) {
            case(?fileAsset) {
                //update the hashmap
                fileAsset.put(file_name, addr_);
                name_owner.put(file_name, msg.caller);
                name_address.put(file_name, addr_);
                //addFileChanger(file_name, msg.caller);
                //addFileViewer(file_name, msg.caller);
                "successfully upload";
            };
            case(_){
                // create the accout and upload the file address
                "you have no accout, please create your accout first";
            };
        };
    };

    //delete file assets
    public shared(msg) func deleteFile(file_name : Text) : async Text{
        //have account
        switch (fileAssets.get(msg.caller)) {
            case(?fileAsset) {
                //delete the hashmap
                fileAsset.delete(file_name);
                name_owner.delete(file_name);
                name_address.delete(file_name);
                //deleteFileChanger(file_name, msg.caller);
                //deleteFileViewer(file_name, msg.caller);
                "successfully delete";
            };
            case(_){
                // create the accout and upload the file address
                "you have no accout, please create your accout first";
            };
        };
    };

    //change file's address
    public shared(msg) func changeFileAddress(file_name : Text, new_addr : Text) : async Text{
        //have account
        if(haveAccount(msg.caller)){
            //file exist
            switch(name_owner.get(file_name)){
                case(?owner){
                    //is owner or changer
                    if(msg.caller == owner or isChanger(file_name, msg.caller)){
                        switch(fileAssets.get(owner)){
                            case(?fileSet){
                                switch(fileSet.replace(file_name, new_addr)){
                                    case(?v){
                                        throw Error.reject("")
                                    };
                                    case(_){
                                        throw Error.reject("change failed")
                                    };
                                };
                                switch(name_address.replace(file_name, new_addr)){
                                    case(?v){
                                        throw Error.reject("")
                                    };
                                    case(_){
                                        throw Error.reject("change failed")
                                    };
                                };
                                "change file" # file_name #" address successfully, new address" # new_addr;
                            };
                            case(_){
                                "change failed";
                            };
                        };
                    }else{
                        "you are not the file owner or changer"
                    }
                };
                case(_){
                    "do not have this file";
                };
            };
        }else{
            "you do not have a account now, please create your account first";
        }
    };

    //search file assets
    public shared(msg) func searchFileAddress(file_name : Text) : async Text {
        if(isViewer(file_name, msg.caller)){
            switch(name_address.get(file_name)){
                case(?file_addr_){
                    file_addr_;
                };
                case(_){
                    "do not have this file";
                };
            };
        }else{
            "you have no right ro view this file's address";
        }
    };

    //wheather approved viewer
    private func isViewer(file_name : Text, user : Principal) : Bool{
        switch(viewer.get(file_name)){
            case(?viewers){
                switch(viewers.get(user)){
                    case(?permit){
                        true;
                    };
                    case(_){
                        false;
                    };
                };
            };
            case(_){
                false;
            };
        };
    };


    private func isChanger(file_name : Text, user : Principal) : Bool{
        switch(changer.get(file_name)){
            case(?changers){
                switch(changers.get(user)){
                    case(?permit){
                        true;
                    };
                    case(_){
                        false;
                    };
                };
            };
            case(_){
                false;
            };
        };
    };

    //add approved viewer
    // some code using is repeat need to improve
    public shared(msg) func addFileViewer(file_name : Text, viewerAddr_ : Principal) : async Text{
        //have account
        if(haveAccount(msg.caller)){
            //file exit
            switch(name_owner.get(file_name)){
                case(?owner){
                    //is owner
                    assert(msg.caller == owner);
                    //append
                    // can be improved inspecting repeat of viewer
                    switch(viewer.get(file_name)){
                        case(?viewers){
                            viewers.put(viewerAddr_, true);
                            "append viewer successfully";
                        };
                        case(_){
                            "do not have this file";
                        };
                    };
                };
                case(_){
                    "file does not exist";
                };
            };
        }else{
            "doesn't exist this account, please create your account first";
        }
    };

    //delete file viewer
    public shared(msg) func deleteFileViewer(file_name : Text, viewerAddr_ : Principal) : async Text{
        //have account
        if(haveAccount(msg.caller)){
            //file exit
            switch(name_owner.get(file_name)){
                case(?owner){
                    //is owner
                    assert(msg.caller == owner);
                    //append
                    // can be improved inspecting repeat of viewer
                    switch(viewer.get(file_name)){
                        case(?viewers){
                            //need error handing<<<<<<<<<<<>>>>>>>>>>>
                            viewers.delete(viewerAddr_);
                            "delete viewer successfully";
                        };
                        case(_){
                            "do not have this file";
                        };
                    };
                };
                case(_){
                    "file does not exist";
                };
            };
        }else{
            "doesn't exist this account, please create your account first";
        }
    };

    //add approved changer
    // some code using is repeat need to improve
    public shared(msg) func addFileChanger(file_name : Text, changerAddr_ : Principal) : async Text{
        //have account
        if(haveAccount(msg.caller)){
            //file exit
            switch(name_owner.get(file_name)){
                case(?owner){
                    //is owner
                    assert(msg.caller == owner);
                    //append
                    // can be improved inspecting repeat of viewer
                    switch(changer.get(file_name)){
                        case(?changers){
                            changers.put(changerAddr_, true);
                            "append changer successfully";
                        };
                        case(_){
                            "do not have this file";
                        };
                    };
                };
                case(_){
                    "file does not exist";
                };
            };
        }else{
            "doesn't exist this account, please create your account first";
        }
    };

    //delete file changer
    public shared(msg) func deleteFileChanger(file_name : Text, changerAddr_ : Principal) : async Text{
        //have account
        if(haveAccount(msg.caller)){
            //file exit
            switch(name_owner.get(file_name)){
                case(?owner){
                    //is owner
                    assert(msg.caller == owner);
                    //append
                    // can be improved inspecting repeat of viewer
                    switch(changer.get(file_name)){
                        case(?changers){
                            //need error handing<<<<<<<<<<<>>>>>>>>>>>
                            changers.delete(changerAddr_);
                            "delete changer successfully";
                        };
                        case(_){
                            "do not have this file";
                        };
                    };
                };
                case(_){
                    "file does not exist";
                };
            };
        }else{
            "doesn't exist this account, please create your account first";
        }
    };

    //query user list

    //changer query list

    //add deledegate user
    //delete delegate user
    //wheather delegate user


 };
