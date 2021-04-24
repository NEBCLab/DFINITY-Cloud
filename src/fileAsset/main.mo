import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor Main{
    //hash table
    //Principal -> HashMap; HashMap - > file_name - file_addressk
    private var fileAssets = HashMap.HashMap<Principal, HashMap.HashMap<Text, Text>>(1, Principal.equal, Principal.hash);
    
    // create account
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
    
    //delete account


    //add file assets
    public shared(msg) func uploadFileAddress(file_name : Text, addr_ : Text) : async Text{
        switch (fileAssets.get(msg.caller)) {
            case(?fileAsset) {
                //update the hashmap
                fileAsset.put(file_name, addr_);
                "successfully upload";
            };
            case(_){
                // create the accout and upload the file address
                "you have no accout, please create your accout first";
            };
        };
    };
    
    //delete file assets
    public shared(msg) func deleteFileAddress(file_name : Text) : async Text{
        switch(fileAssets.get(msg.caller)){
            case(?fileSet){
                switch(fileSet.get(file_name)){
                    case(?value){
                        fileSet.delete(file_name);
                        "delete the file successfully" # value;
                    };
                    case(_){
                        "";
                    };
                };
            };
            case(_){
                "you have no account now";
            };
        };
    };

    //change file's address
    //public shared(msg) func changeFileAddress(file_name : Text, new_addr : Text) : async Text{

    //};


    //search file assets
    public shared(msg) func searchFileAddress(file_name : Text) : async Text {
        switch(fileAssets.get(msg.caller)){
            case(?fileSet){
                switch(fileSet.get(file_name)){
                    case(?file_addr){
                        file_addr;
                    };
                    case(_){
                        "do not have this file";
                    };
                };
            };
            case(_){
                "do not have account now";
            };
        };
    };

};

