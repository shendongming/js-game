###
接龙算法的ai
###


log = (msg ,flag = '')->
    console.log flag + JSON.stringify (msg)

copy_array=(arr)->
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
    rand=(s,e)->
        #闭区间 
        return s+parseInt(Math.random()*(e-s+1))


    rand_array=(arr)->
        for i in [arr.length-1..0]
            j = rand 0,i 
            t=arr[i]
            arr[i]=arr[j]
            arr[j]=t 


    inverNum=(numArr)->
       len = numArr.length;
       count = 0;
       for i  in  [0..(len-2)] #(i = 0; i < len - 1; i ++ ){
            for j in [i+1..len-1]
                if numArr[j] > numArr[i]
                    count++

       
      
       return count


    for c in [0..100]
        t2=[0..(size*size-1)]
        
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

class this.PintuAi
    constructor:(@game)->
        @step=[]
        log 'ai init'
        @size=@game.size
        @data=copy_array @game.data
        @ok_ring =  [
            [1,2,3],
            [4,0,5],
            [7,8,6]
        ]
        @ring_link = [ 1,2,3,5,6,8,7,4 ]
        @ring = [
                [0,0],
                [1,0],
                [2,0],
                [2,1],
                [2,2],
                [1,2],
                [0,2],
                [0,1]
        ]
        @ok_data =  [
            [1,2,3],
            [4,5,6],
            [7,8,0]
        ]
        @ok_ring = []

    start:()->
        @start_ring()

    
    #移动第一行 ok
    get_pos:(n,map=@data)->
        for y in [0..2]
            for x in  [0..2]
                if map[y][x] == n 
                    return  [x,y]

        return  -1

    

    get_val:(p)->
        return @data[p[1]][p[0]]

    

    make_path : (start,end,black_point=[])->
        #位置, 使用尝试法,启发搜索,上下移动,计算距离
        #新增排除黑名单

        black_set={}
        for p in black_point 
            black_set[p[0]+'x'+p[1]]=1
        
        t=start[..]
        path=[]
        while true
            path.push t
            len = len_point t,end

            if len == 0 
                break
            
            try_path=[]

            t1 = t[..]    
            t1[0]--
            if t1[0]>=0 and not black_set[t1[0]+'x'+t1[1]]
                len1 = len_point t1,end
                try_path.push [t1,len1]

            t1 = t[..]    
            t1[0]++
            if t1[0]<@size and not black_set[t1[0]+'x'+t1[1]]
                len1 = len_point t1,end
                try_path.push [t1,len1]

            t1 = t[..]    
            t1[1]++
            if t1[1]<@size and not black_set[t1[0]+'x'+t1[1]]
                len1 = len_point t1,end
                try_path.push [t1,len1]

            t1 = t[..]    
            t1[1]--
            if t1[1]>=0 and not black_set[t1[0]+'x'+t1[1]]
                len1 = len_point t1,end
                try_path.push [t1,len1]

            min_row = null
            for row in try_path
                if row[1]<=try_path[0][1]
                    min_row=row

            if min_row == null
                log 'min_row is null'
                break

            #path.push min_row[0]
            t=min_row[0]

        log ['start',start,'end',end,'path',path ] , 'make_path'
        return path

    move_to:(n,pos)->
        #将一个数字移动到目标
        n_pos = @get_pos(n)
        if equal_array n_pos , pos 

            log  [n_pos , pos],' pos '
            log [ (equal_array n_pos , pos) ]

            return 

        #建立路径

        log n_pos,'to',pos,'最短路径'
        #建立 准备移动的路径
        path2 = @make_path n_pos ,  pos 

        for i in [0..path2.length-2]
            p = path2[i]

            p2 = path2[i+1]
            log [p,'to',p2],'move'
            [@data[p[1]][p[0]],@data[p2[1]][p2[0]] ] = [@data[p2[1]][p2[0]],@data[p[1]][p[0]] ]
            log 'swap'
            debug_data @data

    is_corner :  ( pos )->
        if equal_array pos, [0,0]
            return true
        if equal_array pos, [0,@size-1]
            return true 
        if equal_array pos, [@size-1,0]
            return true 
        if equal_array pos, [@size-1,@size-1]
            return true 
        return false

    ring_next_point:(p,offset=1)->
        #p 顺时针下一点  offset=1
        flag=0
        pos=-1
        for i in [0..@ring.length - 1]
            if equal_array p , @ring[i] 
                pos=i 
                break 
        if pos == -1 
            throw new Error('找不到正确的点')

        pos = pos + offset
        pos = ( pos + @ring.length )  %  @ring.length 
        log ['p',p,'offset',offset,'result',@ring[pos]],'ring_next_point'
        return @ring[pos]

    get_ring_path:(start,end)->
        flag=0
        pos=-1
        pos2=-1
        for i in [0..@ring.length - 1]
            if equal_array start , @ring[i] 
                pos=i 
                break
        for i in [0..@ring.length - 1]
            if equal_array end , @ring[i] 
                pos2=i 
                break
        if pos == -1 or pos2 == -1 
            throw new Error('pos点不在环上')


        path =[]
        index=
        if pos2>pos 
            index=[pos..pos2]

        else 
            index=[pos..(@ring.length-1) ].concat([0..pos2])

        for i in index 
            path.push @ring[i]

        return path


    ring_rota : (data,start,end,offset=1)->
        #将一个对象顺时针转
        
        log 'ring_rota'
        #获取ring的环
        ring_path = @get_ring_path start,end
        log ring_path ,'ring_path'
        for i in ring_path 
            log [i,data[i[1]][i[0]]],'path'

        log ring_path
        log [(ring_path.length-1)..1]

        if offset>0
            for i in [(ring_path.length-1)..1]
                @swap ring_path[i],ring_path[i-1],data 
        else
            #逆时针
            for i in [0..(ring_path.length-2)]
                @swap ring_path[i],ring_path[i+1],data 


    swap : (p1,p2,map=@data)->
        log [p1,p2] , 'swap p1 p2'
        len = len_point p1,p2
        if len >1
            throw new Error('swap point error swap:'+(p1[0]+'x'+p1[1] + '<=>'+p2[0]+'x'+p2[1]))
        debug_data map 
        if map[p2[1]][p2[0]] !=0 and map[p1[1]][p1[0]]!=0
            throw new Error('swap need 0')

        [map[p1[1]][p1[0]] ,map[p2[1]][p2[0]] ] =[map[p2[1]][p2[0]] ,map[p1[1]][p1[0]] ] 

        log 'swap to'
        debug_data map 
        

    move_one : (n_index,n,ok_ring)->
        p= @get_pos(n)
        log '============='
        log ['set n',n,'p',p],'set'
        #1 情况特殊
        if n == 1
            next_p=@ring_next_point(p)
            if @is_corner next_p
                next_p=@ring_next_point next_p
            @swap   next_p,[1,1]
            #1后后面的数字进入中间,让出空位
            debug_data @data

            #@ring_rota @data , p,next_p

            #旋转 n次即可
            path0 = @get_ring_path p,[0,0]
            log path0,'path0' 

            move_len=path0.length - 2 
            for i in [0..move_len]
                @ring_rota @data , @ring_next_point(next_p),@ring_next_point(p)
                p = next_p 
                next_p= @ring_next_point p 
                debug_data @data
            
            log path0,'path0'
            @swap [1,0],[1,1]
            debug_data @data

            @ok_ring.push n 
            return 

        #上一个数的位置
        p_prev = @get_pos(@ring_link[n_index-1]) 

        log ['p_prev',p_prev, 'value:',@get_val(p_prev) ]
        #上一个数后面的位置,就是要移动的数
        p_prev_next = @ring_next_point(p_prev)
        log ['p_prev_next',p_prev_next, 'value:',@get_val(p_prev_next) ]

        #后面的数 就是 目标值
        if @data[p_prev_next[1]][p_prev_next[0]]==n 
            log  [n,'num is ok ']
            debug_data @data
            return

        #将目标数 放到中间
        if not @is_corner p
            log [p ,'is not corner ']
            @swap p,[1,1]


            if  not @is_corner p_prev_next
                #开始旋转 从 p_prev_next 到 p 之间
                @ring_rota @data,p_prev_next,p

                #开始将2放到目标位置
                @swap [1,1],p_prev_next
            else
                #后面的是 开始旋转到 p
                ### 目标 6
                data [1,2,3]
                data [8,0,5]
                data [6,4,7]
                 ["p_prev",[2,1],"value:",5]
                  ["p_prev_next",[2,2],"value:",7]

                ###
                @ring_rota @data,p_prev_next,p 
                @ring_rota @data,p,p_prev_next
                #在移动一次,少移动一个位置 空出来给 目标数
                t_pos=@ring_next_point(p_prev_next)
                @ring_rota @data, t_pos,p 
                @swap [1,1], t_pos
                #准备转回去
                t_pos2= @ring_next_point(@ring_next_point(t_pos))
                @swap t_pos2,[1,1]
                #逆时针,预留一个空格 
                @ring_rota @data,t_pos2,t_pos,-1
                @swap t_pos,[1,1]
                #回复初始状态
                return 
                die()

        else 
            log [p ,'is  corner ']
            #将#上一个数后面的位置 进入中间,旋转用的
            if  not @is_corner p_prev_next
                
                @swap p_prev_next,[1,1]
                p2 = @ring_next_point p #多移动一个
                #逆时针转
                @ring_rota  @data,p_prev_next,p2,-1
                #将刚才的未知数移动另外位置
                @swap p2,[1,1]
                #重新查找p ,一定不是在角了
                
                #是否还需要移动?
                p_prev = @get_pos(@ring_link[n_index-1]) 
                p_prev_next = @ring_next_point(p_prev)
                log ['n',n,'get_val', p_prev_next,@get_val(p_prev_next) ]
                if n == @get_val p_prev_next
                    log ['n',n,'is_ok']
                    return

                return   @move_one(n_index,n,ok_ring)  
            else
                #整体旋转下,这个数还在角落呢
                p2 = @ring_next_point p_prev_next
                @swap p2,[1,1]
                ###
                #整体逆时针 , 将要移动的数移动打中间
                #7 后面的数 进入中间
                # [1,2,3]
                # [8,0,5]
                # [6,4,7]
                    转
                # [1,2,3]
                # [8,4,5]
                # [6,0,7]
                =>  235
                    147    
                    860
                6 到 5 后面
                235
                106
                874
                在转回来

                235
                176
                804
                =>
                123
                875
                046
                =>
                123
                405
                786



                ###
                #整体转
                @ring_rota @data,p2,p_prev_next
                #需要重新计算
                #上一个数的位置
                p_prev = @get_pos(@ring_link[n_index-1]) 

                log ['p_prev',p_prev, 'value:',@get_val(p_prev) ]
                #上一个数后面的位置,就是要移动的数
                p_prev_next = @ring_next_point(p_prev) 
                #后面空出0
                log ' p_prev_next,ring_next_point(p_prev_next)'
                @swap p_prev_next,@ring_next_point(p_prev_next)
                log 'p_prev_next,[1,1]'
                @swap p_prev_next,[1,1]
                p =  @get_pos n
                log 'p, [1,1]'
                @swap p, [1,1] #目标数进入中间

                #刚才的位置旋转
                @ring_rota @data,p_prev_next,p
                @swap p_prev_next, [1,1] #目标数进入预定位置
                #整个区域在转回去
                next2 = @ring_next_point(@ring_next_point(p_prev_next))

                @swap next2,[1,1]
                #逆时针转
                @ring_rota @data,next2,p_prev_next,-1

                #恢复初始状态
                @swap p_prev_next,[1,1]
                return

                die()





    debug_ring:()->
        #调试

        @data=[
             [1,2,3],
             [8,0,5],
             [6,4,7]

        ]
        @move_one 4,6

        

    start_ring:()->
        #环移动法
        return @debug_ring()
          

        #pass
        debug_data @data
        log 'init ring'
        @move_to 0,[1,1]
        #将0 移动到中间
        #开始计算环的位置
        

        
        for n_index in [0..(@ring_link.length-1)]
            n=@ring_link[n_index]
            @move_one n_index,n,@ok_ring


 








# ###
#   start_swap:()->
#         ###
#         交换法 
#         交换法是一个交换两张对调了的拼图的算法，整个算法类似倒车入库。要熟练应用会比旋转法难一点。但是拼图要往高级的打，就一定要会这个算法。。

#         我们还是以上面的拼图为例开始：
#         1 3 4                      1 2 3
#         2 5 7   =》目标             4 5 6
#         8 6                        7 8

#         交换法是先完成第一行，123，目前这个要完成123较为简单。7下5右2右，变成
#         1 3 4
#         2 5
#         8 6 7
#         867543逆时针旋转
#         1    3
#         8 2 4
#         6 7 5
#         2上，最上面的一行123就完成了，接下来简化起见，我们隐藏掉123，进行排序
#         8    4
#         6 7 5
#         接下来是要完成最左边的一行，即4，7要归位。4，7如果归位，那么剩下的3个拼图只要旋转几下就可以归位了。所以核心就在于4，7如何归位。
#         目前这种情况，比较简单：
#         7上6右变成
#         8 7 4
#         6 5
#         8下，7左，4左变成
#         7 4
#         8 6 5
#         然后就简单了，5上6右8右。
#         7 4 5
#         8 6
#         7下4左。好了，74归位。整个拼图就完成了。
#         在很多情况下，交换法会比接龙更节省步数，因为接龙法需要移动所有拼图。上面这种情况比较简单，体现不出交换法的精髓，我们再造一个局：
#         7    8
#         4 6 5
#         这种情况是4，7对调，你会发现一直转来转去，74都对调不过来。交换法的精髓就是以退为进能的借位
#         首先将4移动到现在5的位置:
#         6上4左:
#         7 6 8
#         4 5
#         7下6左8左:
#         6 8
#         7 4 5
#         5上4右8下: 这一步是交换法的精髓所在,将连在一起的4，7切断
#         6    5
#         7 8 4
#         6右7上，7归位
#         7 6 5
#         8 4
#         8左4左，5下6右，现在让出位置，让47重相逢，但是原先相逢的时候4是在7下面的，但是这次的相逢，4是在7的右边
#         7    6
#         8 4 5

#         再次相逢
#         7 4 6
#         8    5
#         感觉是不是眼熟了呢？没错，就是刚刚旋转法一开始的做法。
#         8右7下4左，47归位完成
#         4    6
#         7 8 5

#         先解决 第一行
#         在解决除第一行以外的第一列
#         在移动其他三个

#         ###
#         size = @game.size
#         log 'swap ai start'
#         log @game.data,'data'
#         data=copy_array @game.data
#         ok_data =  [
#             [1,2,3],
#             [4,5,6],
#             [7,8,0]
#         ]
#         #坐标 x 列 y 行

#         ok_pos  = [0..7] #可以移动的位置

#         #移动第一行 ok
#         get_pos=(n)->
#             for y in [0..2]
#                 for x in  [0..2]
#                     if data[y][x] == n 
#                         return  [x,y]

#             return  -1


#         debug_data=(data)->
#             for row in data 
#                 log row ,'data' 
        
#         move_to=(n,pos)->
#             #将一个数字移动到目标
#             n_pos=get_pos(n)
#             if equal_array n_pos , pos 

#                 log  [n_pos , pos],' pos '
#                 log [ (equal_array n_pos , pos) ]
#                 return 

#             #建立路径

#             log n_pos,'to',pos,'最短路径'
#             #建立 准备移动的路径
#             path = make_path n_pos ,  pos
#             log path,'path'

#             p0 = get_pos 0

#             log p0,'p0'

#             path2 = make_path p0, path[1]
#             log path2,'path2'
#             debug_data(data)

#             for i in [0..path2.length-2]
#                 p=path2[i]
#                 p2=path2[i+1]
#                 [data[p[1]][p[0]],data[p2[1]][p2[0]] ] = [data[p2[1]][p2[0]],data[p[1]][p[0]] ]
#                 log 'swap'
#                 debug_data data




#         len_point = (p1,p2)->
#             #计算两点距离
#             len= (p1[0]-p2[0])*(p1[0]-p2[0])+(p1[1]-p2[1])*(p1[1]-p2[1])
#             #log  [p1,p2,'len=',len],'len_point'
#             return len

#         make_path = (start,end)->
#             #位置, 使用尝试法,启发搜索,上下移动,计算距离
            
#             t=start[..]
#             path=[]
#             while true
#                 path.push t
#                 len = len_point t,end

#                 if len == 0 
#                     break
                
#                 try_path=[]

#                 t1 = t[..]    
#                 t1[0]--
#                 if t1[0]>=0
#                     len1 = len_point t1,end
#                     try_path.push [t1,len1]

#                 t1 = t[..]    
#                 t1[0]++
#                 if t1[0]<size
#                     len1 = len_point t1,end
#                     try_path.push [t1,len1]

#                 t1 = t[..]    
#                 t1[1]++
#                 if t1[1]<size
#                     len1 = len_point t1,end
#                     try_path.push [t1,len1]

#                 t1 = t[..]    
#                 t1[1]--
#                 if t1[1]>=0
#                     len1 = len_point t1,end
#                     try_path.push [t1,len1]

#                 min_row = null
#                 for row in try_path
#                     if row[1]<=try_path[0][1]
#                         min_row=row

#                 if min_row == null
#                     log 'min_row is null'
#                     break

#                 #path.push min_row[0]
#                 t=min_row[0]

#             log ['start',start,'end',end,'path',path ] , 'make_path'
#             return path


#         #将 1 移动到0
#         move_to 2 , [0,0]
#         #move_to 6 , [0,1]


# ###



game = new MockGame(3)
game.start()