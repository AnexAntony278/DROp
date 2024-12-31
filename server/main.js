const express=require('express');
const mongoose=require('mongoose');
var port=3000;
const app=express();
app.use(express.json());

app.post('',(req,res)=>{
    console.log(`post req:${JSON.stringify(req.body)}`)
    res.send('POST COMpleted')
});

mongoose.connect('mongodb://localhost:27017/').then(()=>{
    console.log('\nDatabase conection suucesfull');
    app.listen(port,()=>{
        console.log(`\nDROP Server Running on port :${port}`)
    });
}).catch((a)=>{
    console.log(`\nDatabase conection suucesfull\nError:${a} `)
});
