
const mongoose=require('mongoose');
const userSchema=mongoose.Schema({
    name:{
        type:String,
        required:true
    },
    mail:{
        type:String,
        required:true,
        unique:true
    },
    phone:{
        type:String,
        required:true,
        unique:true
    },
    password:{
        type:String,
        required:true,
    }
    ,role:{
        type:String,
        required:true,    
    },
    managerId:{
        type:String,
        required:false
    }
},
{
    timStamps:true
});

const User=mongoose.model('User',userSchema);
module.exports=User; 