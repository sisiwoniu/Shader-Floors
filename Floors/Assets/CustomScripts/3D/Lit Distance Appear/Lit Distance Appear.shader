Shader "Unlit/Lit Distance Appear"
{
    Properties
    {
		[PerRendererData]
        _MainTex ("Texture", 2D) = "white" {}

		_Color("Color", Color) = (1, 1, 1, 1)

		_Speed("MoveSpeed", Range(1, 50)) = 10

		[Toggle]_MoveDown("MoveDown", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
			//これだけでGPU instancingを有効になる
			#pragma multi_compile_instancing

			#pragma shader_feature _MOVEDOWN_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			float _Speed;

			//インスタンスごとのプロパティを定義する
			//インスタンスでそれぞれ設定必要のプロパティ定義
			UNITY_INSTANCING_BUFFER_START(Props)

				UNITY_DEFINE_INSTANCED_PROP(float, _Moved)

			UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata_full v)
            {
                v2f o;

				//インスタンスIDがシェーダーでアクセス可能にする
				UNITY_SETUP_INSTANCE_ID(v);

				//バーテックスシェーダーから、フラグメントシェーダーにインスタンスプロパティをコピーする
				//フラグメントシェーダーでインスタンスプロパティをアクセスするなら、必ず必要
				//UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);

				//移動しながら頂点全体が変形させる処理、メッシュが歪むかもしれないので、ケースバイケースで使う
				//o.vertex.xyz *= UNITY_ACCESS_INSTANCED_PROP(Props, _Moved);

				//処理の本体、これで上昇、下降の演出を実装できている
				#ifdef _MOVEDOWN_ON
				//乗算処理から加算や減算をすると軽くなる。コメント部分の処理と同じ結果になる
				o.vertex.y = _Speed * (1 - UNITY_ACCESS_INSTANCED_PROP(Props, _Moved)) + o.vertex.y; //_Speed - UNITY_ACCESS_INSTANCED_PROP(Props, _Moved * _Speed);
				#else
				o.vertex.y = o.vertex.y - _Speed * (1 - UNITY_ACCESS_INSTANCED_PROP(Props, _Moved));//_Speed - UNITY_ACCESS_INSTANCED_PROP(Props, _Moved * _Speed);
				#endif
                
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
