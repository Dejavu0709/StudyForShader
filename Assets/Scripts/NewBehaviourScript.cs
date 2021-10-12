using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {


        float floatValue;
        float.TryParse("0.01", System.Globalization.NumberStyles.Float, System.Globalization.NumberFormatInfo.InvariantInfo, out floatValue);
        Debug.Log("floatValue: " + floatValue);


   
        float.TryParse("0.01", System.Globalization.NumberStyles.Float, System.Globalization.NumberFormatInfo.CurrentInfo, out floatValue);
        Debug.Log("floatValue2: " + floatValue);

        NumberFormatInfo nfi = new CultureInfo("en-US").NumberFormat;

        CultureInfo ci = Thread.CurrentThread.CurrentCulture.Clone() as CultureInfo;
          //      NumberFormatInfo nfi = ci.NumberFormat;
        
          //set "123456" to "123|456*"
        //     nfi.CurrencyPositivePattern = 1;
        //    nfi.CurrencyGroupSeparator = "|";
          //          nfi.CurrencySymbol = "*";
           //        nfi.CurrencyDecimalDigits = 0;
                   //reset the NumberFormat
       ci.NumberFormat = nfi;
               //set the thread culture to our modified CultureInfo
        Thread.CurrentThread.CurrentCulture = ci;
        float.TryParse("0.01", out floatValue);
        Debug.Log("floatValue3: " + floatValue);


        nfi = new CultureInfo("en-US", false).NumberFormat;

         ci = Thread.CurrentThread.CurrentCulture.Clone() as CultureInfo;
        //      NumberFormatInfo nfi = ci.NumberFormat;

        //set "123456" to "123|456*"
        //     nfi.CurrencyPositivePattern = 1;
        //    nfi.CurrencyGroupSeparator = "|";
        //          nfi.CurrencySymbol = "*";
        //        nfi.CurrencyDecimalDigits = 0;
        //reset the NumberFormat
        ci.NumberFormat = nfi;
        //set the thread culture to our modified CultureInfo
        Thread.CurrentThread.CurrentCulture = ci;
        float.TryParse("0.01", out floatValue);
        Debug.Log("floatValue4: " + floatValue);


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
