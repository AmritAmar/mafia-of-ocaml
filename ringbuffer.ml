module type RingBuffer = 
  sig 
    (* the type contained with the ring buffer *)
    type 'value t 

    (* makes a ring buffer of size x *)
    val make : int -> 'value t 

    (* returns the size of the ring buffer *)
    val size: 'value t -> int 

    (* writes a value to the front of the buffer *)
    val write : 'value t -> 'value -> unit
 
    val fold : ('a -> 'value -> 'a) -> 'a -> 'value t -> 'a 

    (* returns a list view of the buffer *)
    val to_list: 'value t -> 'value list 

    val filter : ('value -> bool) -> 'value t -> 'value list 
  end 


module ArrayBuffer : RingBuffer = struct 
  type 'value t = 'value option array 
  
  let index = ref 0 

  let bound x max = ((x mod max) + max) mod max 

  let modify i amount ary = 
    i := bound (!i + amount) (Array.length ary) 

  let make size = Array.make size None 

  let size ary = Array.length ary 
  
  let write ary value = 
    ary.(!index) <- Some value; 
    modify index 1 ary; ()

  let fold op init ary = 
    let max = Array.length ary in 
    let current = bound (!index - 1) max in 
    let finish = !index in 
    let rec procede cur acc = 
      (match ary.(cur) with 
            (* Halt : We haven't written to this part of the 
             * buffer: *)
        | None -> acc
        | Some x when cur = finish ->
            op acc x 
        | Some x -> 
            procede (bound (cur-1) max) (op acc x)) 
    in 
    procede current init 
  
  let to_list ary = 
    List.rev (fold (fun acc x -> x :: acc) [] ary) 

  let filter cond ary = 
    List.rev 
    (fold (fun acc x -> if cond x then x::acc else acc) [] ary)

end 