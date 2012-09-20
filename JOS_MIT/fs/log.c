#include "fs.h"
#include <inc/fs.h>
#include <kern/spinlock.h>

struct logheader {
  int n;
  int sector[LOGSIZE];
};

struct log {
  struct spinlock lock;
  int start;
  int size;
  int busy;
  int dev;
  struct logheader lh;
};
struct log log;

static void recover_from_log(void);

void
initlog(void)
{
  if(sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

//  __spin_initlock(&log.lock, "log");
  super = diskaddr(1);
  log.start = (*super).size - (*super).nlog;
  log.size = (*super).nlog;
  log.dev = ROOTDEV;
  recover_from_log();
}

static void
install_trans(void)
{
  int tail;
  for(tail = 0; tail < log.lh.n; tail++){
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]);
    memmove(dbuf->data, lbuf->data, BSIZE);
    bwrite(dbuf);
    brelse(lbuf);
    brelse(dbuf);
  }
}

static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for(i = 0; i < log.lh.n; i++){
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
}

static void
write_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for(i = 0; i < log.lh.n; i++){
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
  brelse(buf);
}

static void
recover_from_log(void)
{
  read_head();
  install_trans();  // if committed, copy from log to disk
  log.lh.n = 0;
  write_head();  // clear the log
}

void
begin_trans(void)
{
//  spin_lock(&log.lock);
  while(log.busy) {
//    sleep(&log, &log.lock);
  }
  log.busy = 1;
//  spin_unlock(&log.lock);
}

void
commit_trans(void)
{
  if(log.lh.n > 0) {
    write_head();
    install_trans();
    log.lh.n = 0;
    write_head();
  }
//  spin_lock(&log.lock);
  log.busy = 0;
//  wakeup(&log);
//  spin_unlock(&log.lock);
}

void
log_write(struct buf *b)
{
  int i;
  if(log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if(!log.busy)
    panic("write outside of trans");
  for(i = 0; i < log.lh.n; i++){
    if(log.lh.sector[i] == b->sector)
      break;
  }
  log.lh.sector[i] = b->sector;
  struct buf *lbuf = bread(b->dev, log.start+i+1);
  memmove(lbuf->data, b->data, BSIZE);
  bwrite(lbuf);
  brelse(lbuf);
  if(i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY;  // XXX prevent eviction
}
