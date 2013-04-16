###

拼图游戏

###


$=this.jQuery

log = (msg,tag='') ->
    console.log tag+' '+ JSON.stringify(msg)


if  not this['console']
    this['console']={
        log:(msg)->
            msg
        }


DIRECT_UP = 'up'
DIRECT_DOWN = 'down'
DIRECT_RIGHT = 'right'
DIRECT_LEFT = 'left'

map2arr = (arr)->
    t=[]
    for y in arr 
        t=t.concat y
    return t

die = ()->
    throw new Error('die')

class this.PintuView
    constructor:(@div,@size=3)->

        if @size <3 
            throw new Error('size Error:'+@size)

        @id='game_'+Math.random().toString().substring(2,12);
        id=@id
        @data=[0..(@size*@size-1)]
        @win_data=[1..(@size*@size-1)].concat [0]
        log @win_data ,'win'
        @div.css 'position','relative'
        w = (@div.height()/@size)
        #初始化 界面 
        s = ['<table width=100%><tr><td width=220>']
        s.push ('<table id="'+id+'_table"  width=100%  cellpadding="0" cellspacing="1" style="background-color:#c0c0c0;table-layout:fixed">');
        for i in [0..@size-1]
            s.push  '<tr>'
            for j in [0..@size-1]
                k=i*@size+j;
                s.push '<td id="'+@id+'_td_'+k+'"   align=center valign=center onselect="return false"  onselectstart="return false" onmouseover="this.style.backgroundColor=\'#ccc\'" onmouseout="this.style.backgroundColor=\'#fff\'"  style="background-color:#fff;font-size:28px;width:'+w+'px;height:'+w+'px ">'+k+'</td>'


        s.push ('</table>');
        s.push ('</td><td valign=top>')
        s.push ('<table width=100%><tr><td colspan=2>拼图游戏</td></tr>');
        s.push '<tr style="display:none"><td  width=70>步数</td><td id="'+id+'_step">1</td></tr>';
        s.push '<tr style="display:none"><td >时间</td><td  id="'+id+'_time">1</td></tr>';
        s.push '<tr style="display:none"><td >状态</td><td  id="'+id+'_my_statues">游戏未开始</td></tr>';
        s.push '<tr><td colspan=2><input id="'+id+'_my_but" type=button value="开始" >&nbsp;<input id="'+id+'_my_but_ai" type=button value="自动" >&nbsp;</td></tr></table>';
        s.push '<div  id="'+id+'_msg"  style="position:absolute;width:100px;height:30px;display:none;background-color:#ffffff;border:1px solid green"></div>'
        
        @div.html s.join('')
        $('#'+@id+'_msg').css {
                    'left':((@div.width()-100) / 2)+'px' ,
                    'top':( (@div.height()-30) /2 )+'px' 
                    }
         
        for i in [0..@size-1]
            s.push  '<tr>'
            for j in [0..@size-1]
                k=i*@size+j;
                obj=$('#'+@id+'_td_'+k)
                do (obj,i,j)=>
                    obj.click (e)=>
                        @move [j,i]


        $('#'+@id+'_my_but').click ()=>
            @start()
        $('#'+@id+'_my_but_ai').click ()=>
            @start_ai()

        @start()

    start:()->
        log 'start'
        $('#'+@id+'_msg').html('游戏重新开始').show()
        @random()
        @update()
        setTimeout ()=>
                    $('#'+@id+'_msg').hide()
                ,1000

        

    start_ai:()->
        if __top['Worker']
            try
                work = new Worker('lib/work.js')
                work.postMessage @data
                worker.onmessage (path)=>
                    @demo path
                return 
            catch e 
                e
    

        path = get_path @data
        log path, 'path'
        @demo path

    demo:(path)->
        log path ,'ok result'
        if not path 
            return

        find_0=(data)->
            log data,'find p0'
            for y  in [0..data.length-1]
                for  x in [0..data.length-1]
                    log [data[y][x],x,y],'find'
                    if data[y][x] == 0
                        return [x,y]



        t = setInterval ()=>
                if path[1].length==0
                    clearInterval t 
                    return 
                direct = path[1].splice(0,1)[0]
                p0=find_0(@data)
                log p0,'p0'
                if direct == DIRECT_UP
                    p0[1]--
                if direct == DIRECT_DOWN
                    p0[1]++
                if direct == DIRECT_LEFT
                    p0[0]--
                if direct == DIRECT_RIGHT
                    p0[0]++

                @move p0
            ,200





    update:()->
        
        log 'update '
        for y in [0..@size-1]
            for x in [0..@size-1]
                i= y * @size + x 
                td=$('#'+@id+'_td_'+i);
                if @data[y][x] == 0
                    s = '&nbsp;'
                else 
                    s = @data[y][x]
                td.html s




    random:()->
        #打乱 
        @data = random(@size)
        #@data = [7,6,1,5,3,0,8,2,4]

    

    move:(k)->
        log k,'move'
        log @data,'move'
        len=@size * @size
        [x,y]=k
        log [x,y]

        if x>0 and @data[y][x-1] ==0
            @step++
            return @swap_td(k,[x-1,y])

        if y>0 and @data[y-1][x] ==0
            @step++
            return @swap_td(k,[x,y-1])
        
        if x<@size-1  and @data[y][x+1] ==0
            @step++
            return @swap_td(k,[x+1,y])
        
        if y<@size-1  and @data[y+1][x] ==0
            @step++
            return @swap_td(k,[x,y+1])
        



        

    #//测试是否赢了
    is_win:()->
        win=0
        log  @win_data ,'win_data'
        log  @data ,'data'
        if map2arr(@data).join('') == @win_data.join('')
            win=1

        log 'win',win
        if win
            $('#'+@id+'_msg').html('win!').show()

        return win;




    swap_td:(m,n)->
        #alert([m,n]);
        log 'swap_td',@data
        t=@data[m[1]][m[0]];
        @data[m[1]][m[0]]=@data[n[1]][n[0]];
        @data[n[1]][n[0]]=t;

        if @is_win()
            @my_statues=2;
            try
                window.clearInterval(@time_p);
            catch e
                ''
                #pass

        
        @update()

    td_click:(td)->
        console.log td
        log $(td).id,'td'

    run:()->
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

        
__top=this


log = (msg ,flag = '')->
    console.log flag + JSON.stringify (msg)

copy_array = (arr)->
    #二维数组的deep copy
    t=[]
    for x in arr 
        t.push x[..]
    return t


equal_array=(arr1,arr2)->
    #数组是否相对
    if arr1.length != arr2.length 
        return false
    for i in [0..arr1.length-1]
        if arr1[i]!=arr2[i]
            return false
    return true
# test 
# a=[[1]]
# b=copy_array a

# log a ,'a ' 
# log b , ' b '
# a[0][0]=3 
# log a ,'a ' 
# log b , ' b '

#工具函数

len_point = (p1,p2)->
    #计算两点距离
    len= (p1[0]-p2[0])*(p1[0]-p2[0])+(p1[1]-p2[1])*(p1[1]-p2[1])
    #log  [p1,p2,'len=',len],'len_point'
    return len

debug_data = (data)->
    log 'debug_data'
    for row in data 
        log row ,'data'



random = (size=3)->
    #生成一个打乱的
    log size

    rand=(s,e)->
        #闭区间 
        return s+parseInt(Math.random()*(e-s+1))


    rand_array=(arr)->
        for i in [arr.length-1..0]
            j = rand 0,i 
            t=arr[i]
            arr[i]=arr[j]
            arr[j]=t 


    inverNum = (numArr)->
        len = numArr.length
        count = 0;
        zeroIndex= numArr.indexOf 0
        for i  in  [0..(len-2)] #(i = 0; i < len - 1; i ++ ){
            for j in [(i+1)..len-1]
                if  numArr[i] > numArr[j]>0
                    count++
     
        
        colIndex = zeroIndex % 3 
        lineIndex = (zeroIndex - colIndex) / 3 
        log (lineIndex + colIndex + count)
        return (lineIndex + colIndex + count )   
        
    directs = [DIRECT_DOWN,DIRECT_UP,DIRECT_RIGHT,DIRECT_LEFT]

    rand_move = (arr)->
        flag2={}
        #300步骤 打乱
        c = 0
        while ++c < 400

            p0 = arr.indexOf 0
            x = p0 % size
            y = ( p0 - x  )/size 
            t = directs[rand(0,3)]

            if t == DIRECT_UP and y >0
                y--
            if t == DIRECT_DOWN and y < size-1
                y++
            if t == DIRECT_LEFT and x>0
                x--
            if t == DIRECT_RIGHT and x < size-1
                x++

            p2= y *  size + x 
            if p2 ==p0  
                continue
            arr2=arr[..]
            [ arr2[p2],arr2[p0] ] =[ arr2[p0],arr2[p2] ]
            if flag2[arr2.join('')] 
                continue

            [ arr[p2],arr[p0] ] =[ arr[p0],arr[p2] ]
            flag2[arr.join('')]=1 

        return arr 
 
    t2=[1..(size*size-1)].concat [0]

    rand_move t2  

    temp=[]
    for y in [0..size-1]
        tmp2=[]
        for x in [0..size-1]
            tmp2.push t2[x+y*size]
        temp.push tmp2

    
    #throw 'e'
    return temp




    for c in [0..100]
        t2=[1..(size*size-1)].concat [0]
        
        rand_array t2
        #计算逆序数
        n=inverNum t2 

            
        if n%2 == 0
            #逆序数是偶数的才可以完成游戏的
            temp=[]
            for y in [0..size-1]
                tmp2=[]
                for x in [0..size-1]
                    tmp2.push t2[x+y*size]
                temp.push tmp2

            return temp
            break;
        
        log t2,'奇数'













