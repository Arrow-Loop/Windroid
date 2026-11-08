package org.windroid.lab.control;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;

/** A local graphics/input control, independent of account and store apps. */
public final class MainActivity extends Activity {
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        boolean blockInput = savedInstanceState == null
                && getIntent().getBooleanExtra("lab.block_input_once", false);
        getIntent().removeExtra("lab.block_input_once");
        ControlView view = new ControlView(this, blockInput);
        setContentView(view);
        view.requestFocus();
        Log.i("WindroidLab", "activity created");
    }

    private static final class ControlView extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final float unit;
        private long frames;
        private int taps;
        private float lastX = Float.NaN;
        private float lastY = Float.NaN;
        private boolean animate = true;
        private boolean blockNextInput;

        ControlView(Context context, boolean blockInput) {
            super(context);
            blockNextInput = blockInput;
            unit = getResources().getDisplayMetrics().density;
            paint.setTypeface(Typeface.MONOSPACE);
            paint.setTextSize(22 * unit);
            setFocusableInTouchMode(true);
            setContentDescription("Frame and tap counter. Click to count; space pauses animation.");
        }

        @Override protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            frames++;
            canvas.drawColor((frames / 10) % 2 == 0 ? Color.rgb(20, 54, 76) : Color.rgb(37, 76, 48));
            paint.setColor(Color.WHITE);
            String[] lines = {
                "Windroid Lab Control",
                "Frame: " + frames,
                "Taps: " + taps,
                "View: " + getWidth() + " x " + getHeight(),
                Float.isNaN(lastX) ? "Touch: none" : "Touch: " + Math.round(lastX) + ", " + Math.round(lastY),
                "Animation: " + (animate ? "running" : "paused"),
                "Click to count. Space pauses/resumes.",
                blockNextInput ? "Lab fault armed: first click blocks input for 30s." : "Lab fault: off."
            };
            float y = 48 * unit;
            for (String line : lines) {
                canvas.drawText(line, 24 * unit, y, paint);
                y += 38 * unit;
            }
            if (frames % 10 == 0) Log.i("WindroidLab", "frame=" + frames + " taps=" + taps);
            if (animate && getWindowVisibility() == VISIBLE) postInvalidateDelayed(100);
        }

        @Override public boolean onTouchEvent(MotionEvent event) {
            if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
                requestFocus();
                taps++;
                lastX = event.getX();
                lastY = event.getY();
                Log.i("WindroidLab", "tap=" + taps + " x=" + lastX + " y=" + lastY);
                if (blockNextInput) {
                    blockNextInput = false;
                    Log.w("WindroidLab", "intentional_block_begin duration_ms=30000");
                    SystemClock.sleep(30000);
                    Log.w("WindroidLab", "intentional_block_end");
                }
                invalidate();
            }
            return true;
        }

        @Override public boolean onKeyUp(int keyCode, KeyEvent event) {
            if (keyCode == KeyEvent.KEYCODE_SPACE) {
                animate = !animate;
                Log.i("WindroidLab", "animation=" + animate);
                invalidate();
                return true;
            }
            return super.onKeyUp(keyCode, event);
        }
    }
}
