#include "fs.h"
#include "buf.h"
#include <kern/spinlock.h>

#define NBUF  10

struct {
  struct spinlock lock;
  struct buf buf[NBUF];
  struct buf head;
} bcache;

void
binit(void)
{
  struct buf *b;
  __spin_initlock(&bcache.lock, "bcache");
  //PAGEBREAK!
  //Create linked list of buffer cache
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}

static struct buf*
bget(uint32_t dev, uint32_t sector)
{
  struct buf *b;
  spin_lock(&bcache.lock);
  
loop:
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b->dev == dev && b->sector == sector){
      if(!(b->flags |= B_BUSY)){
        b->flags |= B_BUSY;
        spin_unlock(&bcache.lock);
        return b;
      }
      //sleep(b, &bcache.lock);
      goto loop;
    }
  }
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
      b->dev = dev;
      b->sector = sector;
      b->flags = B_BUSY;
      spin_unlock(&bcache.lock);
      return b;
    }
  }
  panic("bget:no buffers!");
}

struct buf*
bread(uint32_t dev, uint32_t sector)
{
  struct buf *b;
  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
    //iderw(b);
    iderw(b);
}

void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  b->flags |= B_DIRTY;
  //iderw(b);
  iderw(b);
}

void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  spin_lock(&bcache.lock);
  b->next->prev = b->prev;
  b->prev->next = b->next;
  b->next = bcache.head.next;
  b->prev = &bcache.head;
  bcache.head.next->prev = b;
  bcache.head.next = b;

  b->flags &= ~B_BUSY;

  //wakeup(b);
  wakeup(b);
  spin_unlock(&bcache.lock);
}
