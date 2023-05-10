if(!_.waterfall){_.waterfall=1;(function($){var n6=function(a,b,c,d,e){$.yA.call(this,a,b,c,d,e)},o6=function(){$.UA.call(this);this.Fa("waterfall");this.he="waterfall";$.S(this.va,[["dataMode",0,1],["connectorStroke",0,1]])},p6=function(a,b){var c=a.bb().transform(b),d=a.Ab;if(a.ya()){var e=d.left;d=d.width}else e=d.Ta(),d=-d.height;return e+c*d},Dla=function(a,b){for(var c=a.length;c--;){var d=a[c].data;if(d.length&&!d[b].o.missing)return c}return window.NaN},q6=function(a){$.jB.call(this,a);this.D=!1},Ela=function(a){var b=new o6;b.Fg();
b.nd();for(var c=0,d=arguments.length;c<d;c++)b.waterfall(arguments[c]);return b},Fla={eja:"absolute",Eka:"diff"};$.H(n6,$.yA);$.g=n6.prototype;$.g.jE={"%BubbleSize":"size","%RangeStart":"low","%RangeEnd":"high","%XValue":"x","%Diff":"diff","%Absolute":"absolute","%IsTotal":"isTotal"};$.g.xm=function(a,b){var c=n6.B.xm.call(this,a,b);c.diff={value:b.o("diff"),type:"number"};c.absolute={value:b.o("absolute"),type:"number"};c.isTotal={value:b.o("isTotal"),type:""};return c};
$.g.j0=function(){return{prevValue:0,L_:!1,nfa:"absolute"==this.Aa.i("dataMode")}};$.g.N1=function(a,b,c){var d=-1<(0,$.za)(this.um||[],b.o.rawIndex);a=a.get("isTotal");d=!!b.o.missing||d;var e=!(c.L_||d);a=e||($.p(a)?!!a:d);!d||!e&&a?(d=c.nfa?d?c.prevValue:+b.data.value:c.prevValue+(d?0:+b.data.value),b.o.absolute=d,b.o.diff=d-c.prevValue,b.o.isTotal=a,b.o.missing=0,c.L_=!0,c.prevValue=d):b.o.missing=1};$.g.aQ=function(a){return"value"==a?0<=(Number(this.aa().o("diff"))||0):n6.B.aQ.call(this,a)};$.H(o6,$.UA);var Gla={};Gla.waterfall={Bb:32,Eb:2,Jb:[$.vG,$.zG,$.AG,$.EG,$.MG,$.lG],Ib:null,Db:null,zb:$.MF|5767168,xb:"value",vb:"zero"};o6.prototype.Hi=Gla;$.Sy(o6,o6.prototype.Hi);$.g=o6.prototype;$.g.ps=function(){return"waterfall"};$.g.eG=function(){return"value"};$.g.Kr=function(){};$.g.z_=function(a){return+a.o[a.o.isTotal?"absolute":"diff"]};
$.g.O1=function(a,b,c,d){var e=0,f;if(b)for(f=0;f<a.length;f++){var h=a[f].data[b-1];e+=Number(h.o.diff)||0}this.Ma=[];for(f=b;f<=c;f++){for(var k=b=0;k<a.length;k++)h=a[k].data[f],h.o.isTotal||(h.o.stackedZero+=e,h.o.stackedValue+=e,h.o.stackedZeroPrev+=e,h.o.stackedValuePrev+=e,h.o.stackedZeroNext+=e,h.o.stackedValueNext+=e),d.Sc(h.o.stackedValue),d.Sc(h.o.stackedValuePrev),d.Sc(h.o.stackedValueNext),b+=h.o.missing?0:Number(h.o.diff)||0;e+=b;this.Ma.push(e)}};
$.g.PO=function(){o6.B.PO.call(this);this.g?this.g.clear():this.g=$.Nj();var a=this.Xa(),b=this.Do[String($.oa(a))];if(b&&b.length){var c=this.i("connectorStroke");this.g.stroke(c);c=$.Xb(c);this.g.parent(this.P());this.g.zIndex(1E3);this.g.clip(this.Kf());var d=this.ya();a=a.Ou();var e=b[0].ti,f=b[0].lastIndex,h;var k=Dla(b,e);if((0,window.isNaN)(k))var l=h=window.NaN;else{var m=b[k];k=m.data[e].o;var n=a?m.W.Or($.p(k.category)?k.category:e):m.W.xs;h=$.R(p6(this,this.Ma[0]),c);l=k.valueX+n/2}for(var q=
e+1;q<=f;q++){a:{for(k=0;k<b.length;k++)if(!b[k].data[q].o.missing)break a;k=window.NaN}(0,window.isNaN)(k)?k=m=window.NaN:(m=b[k],k=m.data[q].o,n=a?m.W.Or($.p(k.category)?k.category:e):m.W.xs,m=$.R(p6(this,this.Ma[q-e-1]),c),k=k.valueX-n/2);if(!(0,window.isNaN)(l)&&!(0,window.isNaN)(h))if((0,window.isNaN)(k)||(0,window.isNaN)(m))continue;else $.Pz(this.g,d,l,h),$.Qz(this.g,d,k,m);k=Dla(b,q);(0,window.isNaN)(k)?l=h=window.NaN:(m=b[k],k=m.data[q].o,n=a?m.W.Or($.p(k.category)?k.category:e):m.W.xs,h=
$.R(p6(this,this.Ma[q-e]),c),l=k.valueX+n/2)}}};$.g.dt=function(a,b){return new n6(this,this,a,b,!0)};var r6={};$.Vp(r6,0,"dataMode",function(a,b){return $.bk(Fla,a,b||"absolute")});$.Vp(r6,1,"connectorStroke",$.oq);$.U(o6,r6);$.g=o6.prototype;$.g.gs=function(){return!0};
$.g.Ul=function(a,b){var c=[];if("categories"==a){this.U={};for(var d=this.Se(),e,f,h,k={},l=0,m=0;m<d.length;m++)e=d[m],f=$.Gl("risingFill",1,!1),f=f(e,$.Kl,!0,!0),h=$.Vn(f),h in k?this.U[k[h]].W.push(e):(k[h]=l,this.U[l]={W:[e],type:"rising"},c.push({text:"Increase",iconEnabled:!0,iconFill:f,sourceUid:$.oa(this),sourceKey:l++})),f=$.Gl("fallingFill",1,!1),f=f(e,$.Kl,!0,!0),h=$.Vn(f),h in k?this.U[k[h]].W.push(e):(k[h]=l,this.U[l]={W:[e],type:"falling"},c.push({text:"Decrease",iconEnabled:!0,iconFill:f,
sourceUid:$.oa(this),sourceKey:l++})),f=$.Gl("fill",1,!1),f=f(e,$.Kl,!0,!0),h=$.Vn(f),h in k?this.U[k[h]].W.push(e):(k[h]=l,this.U[l]={W:[e],type:"total"},c.push({text:"Total",iconEnabled:!0,iconFill:f,sourceUid:$.oa(this),sourceKey:l++}))}else c=o6.B.Ul.call(this,a,b);return c};
$.g.Sp=function(a,b){if("categories"==this.Df().i("itemsSourceMode")){var c=a.hi(),d=this.U[c];c=d.W;d=d.type;for(var e,f,h,k,l,m,n=0;n<c.length;n++){e=c[n];f=e.Jf();for(m=[];f.advance();){var q=f.la();f.o("missing")||(h=f.o("isTotal"),k=0<=f.o("diff")&&!h,l=0>f.o("diff")&&!h,(h=h&&"total"==d||k&&"rising"==d||l&&"falling"==d)&&m.push(q))}e.Bj(m)}}else return o6.B.Sp.call(this,a,b)};$.g.Rp=function(a,b){if("categories"==this.Df().i("itemsSourceMode"))this.Jd();else return o6.B.Rp.call(this,a,b)};
$.g.Yq=function(a,b){if("default"==this.Df().i("itemsSourceMode"))return o6.B.Yq.call(this,a,b)};$.g.F=function(){var a=o6.B.F.call(this);$.sq(this,r6,a.chart);return a};$.g.X=function(a,b){o6.B.X.call(this,a,b);$.kq(this,r6,a)};$.g.R=function(){$.hd(this.g);o6.B.R.call(this)};var s6=o6.prototype;s6.xScale=s6.Xa;s6.yScale=s6.bb;s6.crosshair=s6.Wg;s6.xGrid=s6.Qm;s6.yGrid=s6.Rm;s6.xMinorGrid=s6.qr;s6.yMinorGrid=s6.tr;s6.xAxis=s6.hh;s6.getXAxesCount=s6.wC;s6.yAxis=s6.ii;s6.getYAxesCount=s6.yC;
s6.getSeries=s6.Te;s6.lineMarker=s6.Cm;s6.rangeMarker=s6.Km;s6.textMarker=s6.Om;s6.palette=s6.bc;s6.markerPalette=s6.pf;s6.hatchFillPalette=s6.me;s6.getType=s6.Pa;s6.addSeries=s6.Gk;s6.getSeriesAt=s6.bi;s6.getSeriesCount=s6.pk;s6.removeSeries=s6.bo;s6.removeSeriesAt=s6.xn;s6.removeAllSeries=s6.$o;s6.getPlotBounds=s6.Kf;s6.xZoom=s6.tq;s6.yZoom=s6.uq;s6.xScroller=s6.ip;s6.yScroller=s6.ur;s6.getStat=s6.Ag;s6.annotations=s6.fk;s6.getXScales=s6.Hx;s6.getYScales=s6.Jx;s6.data=s6.data;$.H(q6,$.jB);$.LF[32]=q6;$.g=q6.prototype;$.g.type=32;$.g.flags=263713;$.g.sh={rising:"path",risingHatchFill:"path",falling:"path",fallingHatchFill:"path",path:"path",hatchFill:"path"};$.g.Ws=function(a){var b=a.o("shapes");for(c in b)b[c].clear();var c=0<=a.o("diff");if(a.o("isTotal")){c="path";var d="hatchFill"}else c?(c="rising",d="risingHatchFill"):(c="falling",d="fallingHatchFill");this.zE(a,b[c],b[d])};
$.g.Wf=function(a,b){var c=0<=a.o("diff");if(a.o("isTotal")){c="path";var d="hatchFill"}else c?(c="rising",d="risingHatchFill"):(c="falling",d="fallingHatchFill");var e={};e[c]=e[d]=!0;e=this.Tc.Uc(b,e);this.zE(a,e[c],e[d])};$.xp.waterfall=Ela;$.G("anychart.waterfall",Ela);}).call(this,$)}