package com.huhan;
/**
 * @author PoetAndPoem
 * @date 2019/03/10
 */
public class App {
    public static void main(String[] args) {
        //1.thread.notify和thread.interrupt最好不要混用；如果必须，则需要明确 表明时间顺序：notify()在
        //interrupt()之前
        
        //2.thread.interrupt后thread 的interrupt flag为true，如果对该thread进行后续操作，且需要重置
        //thread's interrupt flag，使用Thread.interrupted()，虽然看起来有歧义
        Thread r1 = new Thread() {
            /* (non-Javadoc)
             * @see java.lang.Thread#run()
             */
            @Override
            public void run() {
                StringBuffer sb = new StringBuffer();
                sb.append(this.getName() + "'s state is:" + this.getState());
                System.out.println(sb);

                // this.interrupt();
                // sb = new StringBuffer();
                // sb.append(this.getName()+" is interrupted:"+this.isInterrupted());
                // System.out.println(sb);
            }
        };
        Thread r2 = new Thread() {
            /* (non-Javadoc)
             * @see java.lang.Thread#run()
             */
            @Override
            public void run() {
                StringBuffer sb = new StringBuffer();
                sb.append(this.getName() + "'s state is:" + this.getState());
                System.out.println(sb);

            }
        };
        Thread thread1 = new Thread(r1);
        Thread thread2 = new Thread(r2);

        thread1.start();
        thread2.start();
        thread1.interrupt();
        System.out.println(thread1.getName() + " is interrupted:" + thread1.isInterrupted());
        System.out.println(thread2.getName() + " is interrupted:" + thread2.isInterrupted());
    }
}
