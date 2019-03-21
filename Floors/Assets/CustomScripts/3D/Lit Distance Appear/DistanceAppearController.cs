using UnityEngine;

public class DistanceAppearController : MonoBehaviour {

    [SerializeField, Range(0.1f, 10f)]
    private float Radius = 1f;

    [SerializeField, Range(0.1f, 10f)]
    private float AnimSpeed = 1f;

    [SerializeField]
    private GameObject TargetObj;

    private readonly int movedID = Shader.PropertyToID("_Moved");

    private MaterialPropertyBlock block;

    private Renderer s_renderer;

    private Vector3 selfPos;

    private float value = 0f;

    private void Start() {
        block = new MaterialPropertyBlock();

        s_renderer = GetComponent<Renderer>();

        s_renderer.GetPropertyBlock(block);

        selfPos = transform.position;
    }

    private void Update() {
        //半径以内なら元の場所に移動
        if(Vector3.Distance(selfPos, TargetObj.transform.position) < Radius) {
            value = Mathf.Lerp(value, 1f, AnimSpeed * Time.deltaTime);
        } else {
            //逆ならデフォルトに戻す
            value = Mathf.Lerp(value, 0f, AnimSpeed * 0.1f * Time.deltaTime);
        }

        block.SetFloat(movedID, value);
    }

    private void LateUpdate() {
        s_renderer.SetPropertyBlock(block);
    }

}
