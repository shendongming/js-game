###

js 贪吃蛇 ai 演示
单个用户的 求解 情况


###
$=this.jQuery

DIRECT_UP = 'up'
DIRECT_DOWN = 'down'
DIRECT_RIGHT = 'right'
DIRECT_LEFT = 'left'

log = (msg,tag='') ->
    console.log tag+' '+ JSON.stringify(msg)

class this.SnakeView
    constructor:(@div,@width=100,@height=100)->
        @startx=@width>>1
        @starty=@height>>1
        #方向 0上  1右  2下  3左 
        @direct=DIRECT_UP 
        @tick_time=10

        @body=[ [@startx,@starty],[@startx,@starty+1]]
        @black=[-1,-1] #上次刷新该清除的点
        @foods=[-1,-1]
        @null_cell=[]#空白节点列表
        @keys=[]

        #地图标示
        @map=[]
        #初始化 地图
        for y in [0..@height-1]
            t=(0 for x in [0..@width-1])
            @map.push(t)

        for row in @body
            @map[row[1]][row[0]]=1

        @ai=new Ai(this)


    run:()->
        #初始化
        @div.css {'position':'relative', 'border' :'0px solid green','background-color':'#000000'}
        width= @div.width()
        height= @div.height()
        w=(width-1)/(@width)-1
        h=(height-1)/(@height)-1

        for i in [0..@height-1]
            
            for j in [0..@width-1]
                div= $("<div style='overflow:hidden;font-size:10px' id='id#{j}x#{i}' title='#{j}x#{i}'><span id='s#{j}x#{i}'  style='position:relative;top:10px;left:-10px;color:red;display:none;'>1</span></div>").css({'float':'left', 'background-color':'#000000','margin-left':'1px','margin-bottom':'1px', 'width':w+'px','height': h+'px'})
                $(@div).append(div)

        div=$('<div style="background-color:#ffffff;color:red;position:absolute;width:100px;height:30px;text-align:center"></div>')
        div.css('left', (@div.width()-div.width())/2 )
        div.css('top', (@div.height()-div.height()) /2 )
        div.hide()
        @div.append(div)
        @msg=div


        #绑定键盘事件
        $(window).keydown (e)=>
            
            if e.keyCode == 37  # <-
                direct = DIRECT_LEFT
                @keys.push(direct)
                return false
            if e.keyCode == 39 # ->
                direct = DIRECT_RIGHT
                @keys.push(direct)
                return false
            if e.keyCode == 38
                direct = DIRECT_UP
                @keys.push(direct)
                return false
            if e.keyCode == 40
                direct = DIRECT_DOWN
                @keys.push(direct)
                return false

            #实现暂停功能 空格键
            if e.keyCode == 32 
                if @t>0
                    window.clearInterval(@t)
                    @t=0
                else
                    @t=window.setInterval ()=>
                            @tick()
                        ,@tick_time


            log '@direct' + @direct
            

        @food()
        @t=window.setInterval ()=>
                @tick()
            ,@tick_time
        @upview()
        log 'init done'

    #更新视图
    upview:()->
        j=0
        for row in @body
            j++
            if j==1
                @show(row[0],row[1],8)
            else
                @show(row[0],row[1],1)

        if @foods[0]>-1
            @show(@foods[0],@foods[1],2)
        if @black[0]>-1
            @show(@black[0],@black[1],0)
            @black[0]=-1
            @black[1]=-1

        #调试data
         
        for y in [0..@height-1]
            for x in [0..@width-1]
                
                $('#s'+x+'x'+y).html @map[y][x]
                



    show:(x,y,v)->
        if v==1
            $('#id'+x+'x'+y).css('background-color','#ffffff')
        if v==2
            $('#id'+x+'x'+y).css('background-color','#aaffaa')
        if v==8
            $('#id'+x+'x'+y).css('background-color','#ffaaaa')
        if v==0
            $('#id'+x+'x'+y).css('background-color','#000000')

        @map[y][x]=v 
            

    gameover:(v=0)->
        window.clearInterval @t
        if v==0
            @msg.html('game over!').show()
        if v==1
            @msg.html('you win!').show()
        


    #随机产生食物
    food:()->
        
        #简单
        ok=[]
        for y in [0..@height-1]
            for x in [0..@width-1]
                if @map[y][x]==0
                    ok[ok.length]=[x,y]

        
        if ok.length == 0 
            log "your win!"
            return @gameover(1)

        #随机选择一个
        sel=parseInt Math.random()* ok.length
        
        @foods[0] = ok[sel][0]
        @foods[1] = ok[sel][1]
 

    move:(row)-> 
        if @foods[0]==row[0] and @foods[1]==row[1]

            @food() 
            @body[0..0]=[row[..],@body[0]] 
            #更新map
            @map[row[1]][row[0]]=1

        else
            #移动身体 
            head=@body[0] 
            
            if @map[row[1]][row[0]]>0
                return @gameover()

            if head
                @body[0..0]=[row[..],head]
            else 
                @body[0..0]=[row[..]]

            @map[row[1]][row[0]]=1
            t=@body.pop() 
            if t
                #@black=t
                @show(t[0],t[1],0)
            
    #移动        
    step:(row,direct)->

        if direct == DIRECT_UP
            row[1]--
            if row[1]<0
                return false

        if  direct == DIRECT_DOWN
            row[1]++
            if row[1]>=@height
                return false
            
        if direct == DIRECT_LEFT
            row[0]--
            if row[0]<0
                return false
            
        if  direct == DIRECT_RIGHT
            row[0]++
            if row[0]>=@width
                return false
        
        return row


    tick:()->
        @upview()
        @ai.tick()
        
        if @keys.length >0
            @direct=@keys[0]
            @keys[0..0]=[]
        for row in @body
            row=[row[0],row[1]]
            row2=@step(row,@direct)
            
            if row2==false
                return @gameover()
            @move(row2)
            break


        @upview()


class this.Ai
    constructor:(@game)->
        @state=0

    tick:()->

        @slow_ai()
        
        # if @game.body.length<Math.min(@game.width,@game.height)-3
        #     @simple_ai() #用于快速成长
            
        # else
        #     @slow_ai()
        

    slow_ai:()->
        ###
        复杂的ai
        按照一定的策略行走即可
        首先 走到 顶部
        在顺时针走到下边,右下角,左下角,在到左上角之后开始排开绕
        使用最简单的策略,还可以在优化


        ###
        
        if @state == 0
            ###调整状态
            调整沿一边走的状态

            ###
            head=@game.body[0]
            #向上走的步骤
            for i in [0..head[1]-1]
                @game.keys.push(DIRECT_UP)
            #向右的步骤
            for i in  [0.. @game.width-head[0]-2]
                @game.keys.push(DIRECT_RIGHT)

            for i in  [0.. @game.height-2]
                @game.keys.push(DIRECT_DOWN)

            for i in  [0.. @game.width-2]
                @game.keys.push(DIRECT_LEFT)
            
            for i in  [0.. @game.height-2]
                @game.keys.push(DIRECT_UP)

            @state=1
            return

        if @state == 1
            if @game.keys.length == 0
                @state=2 #直接进入状态2

        if @state == 2

            for x in [0..(((@game.width-2)>>1))-1 ]
                
                @game.keys.push(DIRECT_RIGHT)
                for i in [0..@game.height-3]
                    @game.keys.push(DIRECT_DOWN)
                @game.keys.push(DIRECT_RIGHT)
                for i in [0..@game.height-3]
                    @game.keys.push(DIRECT_UP)

            
            
            #@game.gameover()
            #throw 'e'
            @state=3
        if @state ==3 
            if @game.keys.length==0
                @state=4

        if @state ==4 
            @game.keys.push(DIRECT_RIGHT)
            for i in [0..@game.height-2]
                    @game.keys.push(DIRECT_DOWN)
            for i in  [0.. @game.width-2]
                @game.keys.push(DIRECT_LEFT)

            for i in [0..@game.height-2]
                    @game.keys.push(DIRECT_UP)
            @state=5
            return
        if @state == 5
            if @game.keys.length ==1
                @state=1


    simple_ai:()->
        #ai 需要关闭用户的 事件 ,有bug
        
        @game.keys.length=0 #只准备一步,清理队列
        
        head=@game.body[0] 
        #当前方向 


        #下一步可以使用的方向
        ok_dir=@find_ok_dir(@game.body)
        #检查哪个会出界,或者会撞到自己
        min_len=99999999
        min_dir={}
        ok_dir2 = []
        for cur_dir in ok_dir

            #检查基本边界
            result = @game.step(head[..],cur_dir)
            
            if result!=false
                #检查障碍物
                test_v = @game.map[result[1]][result[0]]
                if test_v !=2 and test_v !=0
                    continue

                #哪个里目标更近
                len=@count_len result,@game.foods
                if len<=min_len
                    min_len = len
                    if not min_dir[len]
                        min_dir[len]=[]

                    min_dir[len].push cur_dir
                    

                ok_dir2[ok_dir2.length]=cur_dir

       
        if ok_dir2.length == 0
            log 'no choice'
            return @game.gameover()


        #选择第一个
        @game.direct = min_dir[min_len][0]
        
        

    count_len:(p1,p2)=>
        len=   (p1[0]-p2[0])*(p1[0]-p2[0]) + (p1[1]-p2[1]) * (p1[1]-p2[1])
        return len


    find_ok_dir:(body)->
        if body.length==1
            return  [DIRECT_UP,DIRECT_DOWN,DIRECT_LEFT,DIRECT_RIGHT]
        if body.length>1
            #x坐标相同,直线
            if body[0][0]==body[1][0]
                #y 头 大,不能向上
                if body[0][1]>body[1][1]
                    return  [DIRECT_DOWN,DIRECT_LEFT,DIRECT_RIGHT]
                else
                    return  [DIRECT_UP,DIRECT_LEFT,DIRECT_RIGHT]

            if body[0][1]==body[1][1]
                if body[0][0]>body[1][0]
                    return  [DIRECT_UP,DIRECT_DOWN,DIRECT_RIGHT]
                else
                    return  [DIRECT_UP,DIRECT_DOWN,DIRECT_LEFT]





