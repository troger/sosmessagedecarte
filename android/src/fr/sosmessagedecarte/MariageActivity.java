package fr.sosmessagedecarte;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MariageActivity extends SosActivity {

	private static final String CATEGORY = "mariage";

	private TextView text;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.mariage);

		Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Bodoni SvtyTwo OS ITC TT.dfont");
		text = (TextView) findViewById(R.id.text);
		text.setTypeface(tf);

		Button myButton = (Button) findViewById(R.id.myButton);
		myButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				text.setText(getRandomMessage(CATEGORY));
			}
		});
	}

}