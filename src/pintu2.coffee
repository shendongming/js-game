###
拼图游戏的 广度优先的 穷举算法
3x3的小图很快就完成了

get_path 返回的是数字0的移动方向
up , down 都是相对数字 0
###


if  not this['console']
    this['console']={
        log:(msg)->
            msg
        }


DIRECT_UP = 'up'
DIRECT_DOWN = 'down'
DIRECT_RIGHT = 'right'
DIRECT_LEFT = 'left'

flag = {}
flag['len']=0
console.log flag



log = (msg ,flag = '')->
    console.log flag + JSON.stringify (msg)

ok = '123456780'

map2arr = (arr)->
    t=[]
    for y in arr 
        t=t.concat y
    return t

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



queue=[]

 
search=(data,p0)->
    log data,'search'

    if flag[data[0]]
        return 

    if data[0].join('') == ok 
        return node


    sub=get_sub data
    for node in sub
        queue.push node
        flag[node[0].join('')]=1
        ++flag['len']



    while queue.length 
        #打印队列数量和已经检查的节点总数
        #log queue.length+'/'+(queue.length+flag['len'])
        node = queue.splice(0,1)[0]
        
        #访问节点
        if node[0].join('') == ok 
            return node
 

        sub = get_sub node
        for node2 in sub 
            n=node2[0].join('')
            if !flag[n]
                queue.push node2
                flag[n]=1
                ++flag['len']


get_sub= (data)->

    p0 = data[0].indexOf 0
    t=[]
    #获取各个方向的节点
    p = get_point data[0],p0,DIRECT_DOWN
    t.push [p,data[1].concat(DIRECT_DOWN)] if p 
    p = get_point data[0],p0,DIRECT_UP
    t.push [p,data[1].concat DIRECT_UP] if p 
    p = get_point data[0],p0,DIRECT_RIGHT
    t.push [p,data[1].concat DIRECT_RIGHT] if p 
    p = get_point data[0],p0,DIRECT_LEFT
    t.push [p,data[1].concat DIRECT_LEFT] if p 

    return t

 

get_point = (data,p0,direct)->
    x= p0 % 3
    y= (p0 - x)  / 3
    
    if x == 0 and direct==DIRECT_LEFT
         
        return

    if x == 2 and direct == DIRECT_RIGHT
        
        return 

    if y  == 0 and direct == DIRECT_UP 
        
        return

    if y == 2  and direct  == DIRECT_DOWN
        
        return

     
    data2 = data[..]
    if direct == DIRECT_LEFT
        --x
    if direct ==  DIRECT_RIGHT
        ++x
    if direct == DIRECT_UP
        --y
    if direct == DIRECT_DOWN
        ++y

    p2 = y * 3 +x 
    [data2[p0],data2[p2]] = [data2[p2],data2[p0] ]
    return data2
 
 

this.get_path=(data)->

    for i of flag
        delete flag[i]
    queue.length=0
    
    data = line = map2arr data
    #data =[1,2,3,0,5,6,4,7,8]
    p0 = data.indexOf 0

    log data,'init'
    queue.push [data,[]]
    result={}


    r= search [data,[]] , p0 

    if r
        log line ,'old' 
        log r,'ok'

    else
        log  line,'done' 

    return r

#test ,暂时仅仅支持3x3的拼图
#data=random 3   
#this.get_path   data