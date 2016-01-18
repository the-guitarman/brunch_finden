var addthis_config = {pubid:'ra-4dc68dac6169ab52',ui_header_background:'#990000'};
addthis_config['data_ga_property'] = 'UA-13272780-8';
addthis_config['data_ga_social'] = true;

jQuery('document').ready(function($) {
    $.getScript(
        "//s7.addthis.com/js/300/addthis_widget.js",
        function(){
            addthis.layers({
                theme:'light',
                domain:'www.brunch-finden.de',
                services_exclude:'foursquare,google_plusone,pinterest,100zakladok,2tag,2linkme,a97abi,addressbar,adfty,adifni,advqr,amazonwishlist,amenme,aim,aolmail,apsense,arto,azadegi,baang,baidu,balltribe,beat100,biggerpockets,bitly,bizsugar,bland,blinklist,blogger,bloggy,blogkeen,blogmarks,blurpalicious,bobrdobr,bonzobox,socialbookmarkingnet,bookmarkycz,bookmerkende,box,brainify,bryderi,buddymarks,buffer,buzzzy,camyoo,care2,foodlve,chiq,cirip,citeulike,classicalplace,cleanprint,cleansave,cndig,colivia,technerd,cosmiq,cssbased,curateus,delicious,digaculturanet,digg,diggita,digo,diigo,domelhor,dotnetshoutout,douban,draugiem,dropjack,dudu,dzone,efactor,ekudos,elefantapl,email,mailto,embarkons,evernote,extraplay,ezyspot,stylishhome,fabulously40,informazione,thefancy,fark,farkinda,fashiolista,favable,faves,favlogde,favoritende,favorites,favoritus,financialjuice,flaker,folkd,formspring,thefreedictionary,fresqui,friendfeed,funp,fwisp,gamekicker,gg,giftery,gigbasket,givealink,gmail,govn,goodnoows,google,googleplus,googletranslate,greaterdebater,hackernews,hatena,gluvsnap,hedgehogs,historious,hootsuite,hotklix,hotmail,w3validator,identica,ihavegot,indexor,instapaper,iorbix,irepeater,isociety,iwiw,jamespot,jappy,jolly,jumptags,kaboodle,kaevur,kaixin,ketnooi,kindleit,kledy,kommenting,latafaneracat,librerio,lidar,linkedin,linksgutter,linkshares,linkuj,livejournal,lockerblogger,logger24,mymailru,margarin,markme,mashant,mashbord,me2day,meinvz,mekusharim,memonic,memori,mendeley,meneame,live,misterwong,misterwong_de,mixi,moemesto,moikrug,mrcnetworkit,myspace,myvidster,n4g,naszaklasa,netlog,netvibes,netvouz,newsmeback,newstrust,newsvine,nujij,odnoklassniki_ru,oknotizie,openthedoor,orkut,oyyla,packg,pafnetde,pdfonline,pdfmyurl,phonefavs,planypus,plaxo,plurk,pocket,posteezy,print,printfriendly,pusha,qrfin,qrsrc,quantcast,qzone,reddit,rediff,redkum,researchgate,safelinking,scoopat,scoopit,sekoman,select2gether,shaveh,shetoldme,sinaweibo',
                services_compact:'facebook,google_plusone_share,twitter,pinterest_share',
                services_expanded:'facebook,google_plusone_share,twitter,pinterest_share', 
                share:{
                    //theme:'transparent',
                    theme:'light',
                    position:'left',
                    numPreferredServices:4,
                    services:'facebook,google_plusone_share,twitter,pinterest_share',
                    offset:{top:'23px'},
                    desktop:true,
                    mobile:true
                },
                mobile:{
                    buttonBarPosition:'bottom',
                    buttonBarTheme:'light',
                    mobile:true
                },
                responsive: {
                    maxWidth:'1199px',
                    minWidth:'1200px'
                }
            })
        }
    );
});
