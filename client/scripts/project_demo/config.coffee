'use strict';
define(["angularAMD"],(angularAMD)->
    angularAMD.publicRouter=[
        {name:'signin',url:'/user/signin',text:'登录',icon:'fa-pencil',show:true,wide:true}
        {name:'signup',url:'/user/signup',text:'注册',icon:'fa-pencil',show:true,wide:true}
        {name:'404',url:'/404',text:'错误页面',icon:'fa-pencil',show:true,wide:true}
        {name:'500',url:'/500',text:'服务器错误',icon:'fa-pencil',show:false,wide:true}
        {name:'blank',url:'/user/blank',text:'空白页',icon:'fa-pencil',show:false,wide:true}
        {name:'forgot-password',url:'/user/forgot-password',text:'忘记密码',icon:'fa-pencil',show:true,wide:true}
        {name:'lock-screen',url:'/user/lock-screen',text:'锁屏',icon:'fa-pencil',show:true,wide:true}
        {name:'profile',url:'/user/profile',text:'个人配置',icon:'fa-pencil',show:true,wide:false}
    ]
    angularAMD.authMethod = 'token'
    angularAMD.domian = '.'
    angularAMD.pageTransitionOpts = [
            name: 'Scale up'
            class: 'ainmate-scale-up'
        ,
            name: 'Fade up'
            class: 'animate-fade-up'
        ,
            name: 'Slide in from right'
            class: 'ainmate-slide-in-right'
        ,
            name: 'Flip Y'
            class: 'animate-flip-y'
    ]
    angularAMD.admin =
        lang:'中文'
        layout: 'wide'                                  # 'boxed', 'wide'
        menu: 'vertical'                                # 'horizontal', 'vertical'
        fixedHeader: true                               # true, false
        fixedSidebar: false                             # true, false
        pageTransition: angularAMD.pageTransitionOpts[0]    # unlimited, check out "_animation.scss"
    angularAMD.main =
        brand: 'BotSite'
        title: 'BotSite'
        name: 'Lisa Doe' # those which uses i18n directive can not be replaced for now.
    angularAMD.color =
        primary:    '#248AAF'
        success:    '#3CBC8D'
        info:       '#29B7D3'
        infoAlt:    '#666699'
        warning:    '#FAC552'
        danger:     '#E9422E'
    angularAMD.lang =
        'English':
            'file':'EN-US'
            'class':'flags-american'
        'Español':
            'file':'ES-ES'
            'class':'flags-spain'
        '日本語':
            'file':'JA-JP'
            'class':'flags-japan'
        '中文':
            'file':'ZH-TW'
            'class':'flags-china'
        'Deutsch':
            'file':'DE-DE'
            'class':'flags-germany'
        'français':
            'file':'FR-FR'
            'class':'flags-france'
        'Italiano':
            'file':'IT-IT'
            'class':'flags-italy'
        'Portugal':
            'file':'PT-BR'
            'class':'flags-portugal'
        'Русский язык':
            'file':'RU-RU'
            'class':'flags-russia'
        '한국어':
            'file':'KO-KR'
            'class':'flags-korea'
    angularAMD.deurl =
        'user':
            signup:
                method:'post'
                url:'{domain}/public/signup'
            signin:
                method:'post'
                url:'{domain}/public/authenticate'
            lock:
                method:'get'
                url:'{domain}/user/lock'
            promise:
                method:'get'
                url:'{domain}/user/promise'
            unlock:
                method:'post'
                url:'{domain}/user/unlock'
            setting:
                method:'post'
                url:'{domain}/user/setting'
            chpasswd:
                method:'post'
                url:'{domain}/user/chpasswd'
            me:
                method:'get'
                url:'{domain}/user/me'
            signout:
                method:'get'
                url:'{domain}/user/logout'
            login:
                method:'get'
                url:'{domain}/accounts/login/'
    angularAMD.loadingHTML = """
                                <div class="loading-spinner">
                                    <div class="loading-spinner-container container1">
                                        <div class="circle1"></div>
                                        <div class="circle2"></div>
                                        <div class="circle3"></div>
                                        <div class="circle4"></div>
                                    </div>
                                    <div class="loading-spinner-container container2">
                                        <div class="circle1"></div>
                                        <div class="circle2"></div>
                                        <div class="circle3"></div>
                                        <div class="circle4"></div>
                                    </div>
                                    <div class="loading-spinner-container container3">
                                        <div class="circle1"></div>
                                        <div class="circle2"></div>
                                        <div class="circle3"></div>
                                        <div class="circle4"></div>
                                    </div>
                                </div>
                             """
    angularAMD.prefix = project

    return angularAMD
)
